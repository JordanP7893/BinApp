//
//  BinDaysProvider.swift
//  BinApp
//
//  Created by Jordan Porter on 28/11/2022.
//  Copyright © 2022 Jordan Porter. All rights reserved.
//

import Foundation

protocol BinListViewModelProtocol: ObservableObject {
    var address: AddressData? { get set }
    var binDays: [BinDays] { get set }
    var binNotifications: BinNotifications { get set }
}

@MainActor
class BinListViewModel: ObservableObject {
    @Published var address: AddressData? {
        didSet {
            if let address, oldValue != nil {
                Task {
                    addressDataController.saveAddressData(address)
                    await fetchDataFromTheNetwork(usingId: address.id)
                    await updateNotifications()
                }
            }
        }
    }
    @Published var binDays: [BinDays] = [] {
        didSet {
            if binDays != oldValue {
                binDaysDataController.saveBinData(binDays)
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
    
    let addressDataController: BinAddressDataProtocol
    let binDaysDataController: BinDaysDataProtocol
    let notificationDataController: NotificationDataProtocol
    
    init(
        addressDataController: BinAddressDataProtocol,
        binDaysDataController: BinDaysDataProtocol,
        notificationDataController: NotificationDataProtocol
    ) {
        self.addressDataController = addressDataController
        self.binDaysDataController = binDaysDataController
        self.notificationDataController = notificationDataController
        
        self.address = addressDataController.fetchAddressData()
        
        do {
            self.binNotifications = try notificationDataController.fetchNotificationState()
        } catch {
            self.binNotifications = .init()
        }
        
        if let address {
            do {
                self.binDays = try binDaysDataController.fetchLocalBinDays()
            } catch {
                Task {
                    await fetchDataFromTheNetwork(usingId: address.id)
                }
            }
        }
    }
    
    func onRefresh() async {
        if let address {
            await fetchDataFromTheNetwork(usingId: address.id)
            await updateNotifications()
        }
    }
    
    func onSavePress(address: StoreAddress) {
        self.address = .init(
            id: address.premisesId,
            title: address.formattedAddress
        )
    }
    
}

// MARK: Private Methods

extension BinListViewModel {
    private func fetchDataFromTheNetwork(usingId addressID: Int) async {
        do {
            self.binDays = try await binDaysDataController.fetchNetworkBinDays(id: addressID)
        } catch {
            print(error)
        }
    }

    private func updateNotifications() async {
        do {
            try notificationDataController.saveNotificationState(binNotifications)
            
            guard !binDays.isEmpty else { return }
            binDays = updateBinDaysWithNotifications(binDays: binDays, notifications: binNotifications)
            try await notificationDataController.setupBinNotification(for: binDays, at: binNotifications)
        } catch {
            print(error)
        }
    }
    
    private func updateBinDaysWithNotifications(binDays: [BinDays], notifications: BinNotifications) -> [BinDays] {
        let calendar = Calendar.current
        
        return binDays.map { binDay in
            var updatedBinDay = binDay

            if notifications.types.contains(binDay.type) {
                if let morningTime = notifications.morningTime {
                    updatedBinDay.notificationMorning = combine(date: binDay.date, time: morningTime, calendar: calendar)
                }
                
                if let eveningTime = notifications.eveningTime, let previousDate = calendar.date(byAdding: .day, value: -1, to: binDay.date) {
                    updatedBinDay.notificationEvening = combine(date: previousDate, time: eveningTime, calendar: calendar)
                }
            }

            return updatedBinDay
        }
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
