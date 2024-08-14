//
//  BinDaysProvider.swift
//  BinApp
//
//  Created by Jordan Porter on 28/11/2022.
//  Copyright © 2022 Jordan Porter. All rights reserved.
//

import Foundation

@MainActor
class BinDaysProvider: ObservableObject {
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
    @Published var binNotifications: BinNotifications = BinNotifications(
        morning: false,
        morningTime: .now,
        evening: false,
        eveningTime: .now,
        types: [0: false, 1: false, 2: false]
    ) {
        didSet {
            Task {
                await updateNotifications()
            }
        }
    }

    let addressDataController = BinAddressDataController()
    let binDaysDataController = BinDaysDataController()
    let notificationDataController = NotificationDataController()
    
    func updateAddress(newAddress: AddressData) {
        address = newAddress
        addressDataController.saveAddressData(newAddress)
    }
    
    func fetchAddress() {
        address = addressDataController.fetchAddressData()
    }

    func fetchBinDays(addressID: Int) async throws {
        if let binDays = binDaysDataController.fetchBinData() {
            self.binDays = binDays.sorted { $0.date < $1.date }
        } else {
            try await fetchDataFromTheNetwork(usingId: addressID)
        }
    }

    func fetchDataFromTheNetwork(usingId addressID: Int) async throws {
        self.binDays = try await binDaysDataController.fetchBinDates(id: addressID)
        self.binDays = binDays.sorted { $0.date < $1.date }
        let _ = await updateNotifications()
    }

    func fetchNotifications() {
        if let binNotifications = notificationDataController.fetchNotificationState() {
            self.binNotifications = binNotifications
        }
    }

    func updateNotifications() async -> Bool {
        return await notificationDataController.setupBinNotification(for: binDays, at: binNotifications)
    }
    
}
