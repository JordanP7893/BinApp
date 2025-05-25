//
//  BinDaysProvider.swift
//  BinApp
//
//  Created by Jordan Porter on 28/11/2022.
//  Copyright © 2022 Jordan Porter. All rights reserved.
//

import Foundation
import UserNotifications

@MainActor
class BinListViewModel: ObservableObject {
    @Published var address: AddressData? {
        didSet {
            if let address {
                Task {
                    do {
                        try addressDataService.saveAddressData(address)
                    } catch {
                        errorMessage = "Failed to save address."
                    }
                    await fetchDataFromTheNetwork(usingId: address.id)
                }
            }
        }
    }
    @Published var binDays: [BinDays] = [] {
        didSet {
            if binDays != oldValue {
                do {
                    if !binDays.contains(where: { $0.type == .food }) {
                        var binTypesMutated = binTypes
                        binTypesMutated.removeAll(where: { $0 == .food })
                        binTypes = binTypesMutated
                    }
                    try binDaysDataService.saveBinData(binDays)
                } catch {
                    errorMessage = "Failed to save bin dates."
                }
            }
        }
    }
    @Published var binNotifications: BinNotifications {
        didSet {
            if binNotifications != oldValue {
                Task {
                    await updateNotifications(with: binNotifications)
                }
            }
        }
    }
    @Published var isLoading = true
    @Published var showError = false
    @Published var errorMessage: String? {
        didSet {
            if errorMessage == nil {
                showError = false
            } else {
                showError = true
            }
        }
    }
    @Published var binTypes: [BinType] = BinType.allCases
    
    let addressDataService: BinAddressDataProtocol
    let binDaysDataService: BinDaysDataProtocol
    let notificationDataService: NotificationProtocol
    
    private var timer: Timer?
    
    init(
        addressDataService: BinAddressDataProtocol,
        binDaysDataService: BinDaysDataProtocol,
        notificationDataService: NotificationProtocol
    ) {
        self.addressDataService = addressDataService
        self.binDaysDataService = binDaysDataService
        self.notificationDataService = notificationDataService
        
        do {
            self.address = try addressDataService.fetchAddressData()
        } catch {
            errorMessage = "Failed to fetch address data."
            isLoading = false
        }
        self.binNotifications = notificationDataService.fetchNotificationState()
        
        do {
            self.binDays = try binDaysDataService.fetchLocalBinDays()
            isLoading = false
        } catch {
            Task {
                await fetchDataFromTheNetwork(usingId: address?.id)
            }
        }
        
        scheduleTimer()
    }
    
    func onRefresh() async {
        await fetchDataFromTheNetwork(usingId: address?.id)
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func onLocalRefresh() {
        if let binDays = try? binDaysDataService.fetchLocalBinDays() {
            self.binDays = binDays
        }
    }
    
    func onSavePress(address: StoreAddress) {
        self.address = .init(
            id: address.premisesId,
            title: address.formattedAddress
        )
    }
    
    func onDonePress(for bin: BinDays) {
        notificationDataService.markBinDone(binId: bin.id)
    }
    
    func onRemindMeLaterPress(at time: TimeInterval, for bin: BinDays) {
        notificationDataService.snoozeBin(bin, for: time, isMorning: bin.isMorningPending)
    }
    
    func onRemindMeTonightPress(for bin: BinDays) {
        notificationDataService.tonightBin(bin)
    }
    
    func scheduleTimer() {
        cancelTimer()
        
        Task {
            let now = Date()
            let calendar = Calendar.current
            let nextMinute = calendar.nextDate(after: now, matching: DateComponents(second: 0), matchingPolicy: .strict)
            let delay = nextMinute?.timeIntervalSince(now) ?? 0

            // Convert delay to nanoseconds for Task.sleep
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            self.objectWillChange.send()
            self.startRepeatingTimer()
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
    }
}

// MARK: Private Methods

extension BinListViewModel {
    private func startRepeatingTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.objectWillChange.send()
        }
    }
    
    private func fetchDataFromTheNetwork(usingId addressID: Int?) async {
        guard let addressID else { return }
        
        do {
            self.binDays = try await binDaysDataService.fetchNetworkBinDays(id: addressID)
            let notificationState = notificationDataService.fetchNotificationState()
            await updateNotifications(with: notificationState)
        } catch {
            errorMessage = "Failed to fetch bin dates. Please try again later."
        }
        isLoading = false
    }

    private func updateNotifications(with notificationState: BinNotifications) async {
        do {
            try notificationDataService.saveNotificationState(binNotifications)
            if notificationState.morningTime == nil && notificationState.eveningTime == nil { return }
            
            guard !binDays.isEmpty else { return }
            binDays = updateBinDaysWithNotifications(binDays: binDays, notifications: binNotifications)
            try await notificationDataService.setupBinNotification(for: binDays, at: binNotifications)
        } catch {
            errorMessage = "Failed to update notifications."
        }
    }
    
    private func updateBinDaysWithNotifications(binDays: [BinDays], notifications: BinNotifications) -> [BinDays] {
        let calendar = Calendar.current
        
        let binDaysWithNotifications = binDays.map { binDay in
            var updatedBinDay = binDay

            if notifications.types.contains(binDay.type) {
                if let morningTime = notifications.morningTime {
                    updatedBinDay.notificationMorning = combine(date: binDay.date, time: morningTime, calendar: calendar)
                } else {
                    updatedBinDay.notificationMorning = nil
                }
                
                if let eveningTime = notifications.eveningTime, let previousDate = calendar.date(byAdding: .day, value: -1, to: binDay.date) {
                    updatedBinDay.notificationEvening = combine(date: previousDate, time: eveningTime, calendar: calendar)
                } else {
                    updatedBinDay.notificationEvening = nil
                }
                
                /// Uncomment to trigger test notification for the first bin after 10 seconds
//                if binDays.firstIndex(of: binDay) == 0 {
//                    updatedBinDay.notificationEvening = .now.addingTimeInterval(10)
//                }
            }

            return updatedBinDay
        }
        
        return binDaysWithNotifications
    }
    
    private func combine(date: Date, time: Date, calendar: Calendar, previousDay: Bool = false) -> Date? {
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second
        
        return calendar.date(from: combinedComponents)
    }
}
