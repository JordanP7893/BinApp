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
    @Published var address: AddressData? { didSet { onChangeOf(address: address) }}
    @Published var binDays: [BinDays] = []
    @Published var binNotifications: BinNotifications
    @Published var isLoading = true
    @Published var showError = false
    @Published var errorMessage: String? { didSet { onChangeOf(errorMessage: errorMessage) } }
    @Published var binTypes: [BinType] = BinType.allCases
    
    let addressDataService: BinAddressDataProtocol
    let binDaysDataService: BinDaysDataProtocol
    let notificationDataService: NotificationDataProtocol
    let repeatingTimerService: RepeatingTimerService
    let userNotificationService: UserNotificationProtocol
    
    init(
        addressDataService: BinAddressDataProtocol,
        binDaysDataService: BinDaysDataProtocol,
        notificationDataService: NotificationDataProtocol,
        repeatingTimerService: RepeatingTimerService = RepeatingTimerService(),
        userNotificationService: UserNotificationProtocol
    ) {
        self.addressDataService = addressDataService
        self.binDaysDataService = binDaysDataService
        self.notificationDataService = notificationDataService
        self.repeatingTimerService = repeatingTimerService
        self.userNotificationService = userNotificationService
        
        self.binNotifications = .init()
    }
    
    func onAppear() {
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
        userNotificationService.markBinDone(id: bin.id)
    }
    
    func onRemindMeLaterPress(at time: TimeInterval, for bin: BinDays) {
        userNotificationService.snooze(bin, for: time, isMorning: bin.isMorningPending)
    }
    
    func onRemindMeTonightPress(for bin: BinDays) {
        userNotificationService.snoozeUntilTonight(bin)
    }
    
    func scheduleTimer() {
        repeatingTimerService.schedule(startAtNextExactMinute: true) {
            self.objectWillChange.send()
        }
    }
    
    func cancelTimer() {
        repeatingTimerService.cancel()
    }
}

// MARK: Change of value

extension BinListViewModel {
    func onChangeOf(address: AddressData?) {
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
    
    func onChangeOfBinDays(newValue: [BinDays], oldValue: [BinDays]) {
        if newValue != oldValue {
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
    
    func onChangeOfBinNotifications(newValue: BinNotifications?, oldValue: BinNotifications?) {
        if let newValue, newValue != oldValue {
            Task {
                await updateNotifications(with: newValue)
            }
        }
    }
    
    func onChangeOf(errorMessage: String?) {
        if errorMessage == nil {
            showError = false
        } else {
            showError = true
        }
    }
}

// MARK: Private Methods

extension BinListViewModel {    
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
            try notificationDataService.saveNotificationState(notificationState)
            if notificationState.morningTime == nil && notificationState.eveningTime == nil { return }
            
            guard !binDays.isEmpty else { return }
            binDays = updateBinDaysWithNotifications(binDays: binDays, notifications: notificationState)
            try await userNotificationService.setupBinNotification(for: binDays, at: notificationState)
        } catch {
            errorMessage = "Failed to update notifications."
        }
    }
    
    private func updateBinDaysWithNotifications(binDays: [BinDays], notifications: BinNotifications) -> [BinDays] {
        let binDaysWithNotifications = binDays.map { binDay in
            var updatedBinDay = binDay

            if notifications.types.contains(binDay.type) {
                if let morningTime = notifications.morningTime {
                    updatedBinDay.notificationMorning = binDay.date.combineWith(time: morningTime)
                } else {
                    updatedBinDay.notificationMorning = nil
                }
                
                if let eveningTime = notifications.eveningTime, let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: binDay.date) {
                    updatedBinDay.notificationEvening = previousDate.combineWith(time: eveningTime)
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
}

