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
            if let address, oldValue != nil {
                Task {
                    addressDataService.saveAddressData(address)
                    await fetchDataFromTheNetwork(usingId: address.id)
                }
            }
        }
    }
    @Published var binDays: [BinDays] = [] {
        didSet {
            if binDays != oldValue {
                do {
                    try binDaysDataService.saveBinData(binDays)
                } catch {
                    print(error)
                }
            }
        }
    }
    @Published var binNotifications: BinNotifications {
        didSet {
            if binNotifications != oldValue {
                Task {
                    await updateNotifications()
                }
            }
        }
    }
    
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
        
        self.address = addressDataService.fetchAddressData()
        self.binNotifications = notificationDataService.fetchNotificationState()
        
        do {
            self.binDays = try binDaysDataService.fetchLocalBinDays()
        } catch {
            self.binDays = []
        }
        
        scheduleTimer()
    }
    
    func onAppear() async {
        if binDays.isEmpty {
            await fetchDataFromTheNetwork(usingId: address?.id)
        }
    }
    
    func onRefresh() async {
        await fetchDataFromTheNetwork(usingId: address?.id)
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
        } catch {
            print(error)
        }
        await updateNotifications()
    }

    private func updateNotifications() async {
        do {
            try notificationDataService.saveNotificationState(binNotifications)
            
            guard !binDays.isEmpty else { return }
            binDays = updateBinDaysWithNotifications(binDays: binDays, notifications: binNotifications)
            try await notificationDataService.setupBinNotification(for: binDays, at: binNotifications)
        } catch {
            print(error)
        }
    }
    
    private func updateBinDaysWithNotifications(binDays: [BinDays], notifications: BinNotifications) -> [BinDays] {
        let calendar = Calendar.current
        
        let binDaysWithNotifications = binDays.map { binDay in
            var updatedBinDay = binDay

            if notifications.types.contains(binDay.type) {
                if let morningTime = notifications.morningTime {
                    updatedBinDay.notificationMorning = combine(date: binDay.date, time: morningTime, calendar: calendar)
                }
                
                if let eveningTime = notifications.eveningTime, let previousDate = calendar.date(byAdding: .day, value: -1, to: binDay.date) {
                    updatedBinDay.notificationEvening = combine(date: previousDate, time: eveningTime, calendar: calendar)
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
