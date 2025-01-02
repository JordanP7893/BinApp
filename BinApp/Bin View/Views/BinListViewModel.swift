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
            if let address {
                Task {
                    try await fetchDataFromTheNetwork(usingId: address.id)
                }
            }
        }
    }
    @Published var binDays: [BinDays] = []
    @Published var binNotifications: BinNotifications = BinNotifications() {
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
    }
    
    func onAppear() async {
        fetchNotifications()
        if let address {
            try? await fetchBinDays(addressID: address.id)
        } else {
            fetchAddress()
        }
    }
    
    func onRefresh() async {
        if let address {
            try? await fetchDataFromTheNetwork(usingId: address.id)
        }
    }
    
    func onSavePress(address: StoreAddress) {
        updateAddress(newAddress: .init(id: address.premisesId, title: address.formattedAddress))
    }
    
    private func updateAddress(newAddress: AddressData) {
        address = newAddress
        addressDataController.saveAddressData(newAddress)
    }
    
    private func fetchAddress() {
        address = addressDataController.fetchAddressData()
    }

    private func fetchBinDays(addressID: Int) async throws {
        if let binDays = binDaysDataController.fetchBinData(skipDateCheck: false) {
            self.binDays = binDays.sorted { $0.date < $1.date }
        } else {
            try await fetchDataFromTheNetwork(usingId: addressID)
        }
    }

    private func fetchDataFromTheNetwork(usingId addressID: Int) async throws {
        let fetchedBins = try await binDaysDataController.fetchBinDates(id: addressID)
        self.binDays = fetchedBins.sorted { $0.date < $1.date }
        await updateNotifications()
    }

    private func fetchNotifications() {
        if let binNotifications = notificationDataController.fetchNotificationState() {
            self.binNotifications = binNotifications
        }
    }

    private func updateNotifications() async {
        notificationDataController.saveNotificationState(binNotifications)
        binDays = updateBinDaysWithNotifications(binDays: binDays, notifications: binNotifications)
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
