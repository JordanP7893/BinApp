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
    
    @Published var binDays: [BinDays] = []
    
    let binDaysDataController = BinDaysDataController()
    let notificationDataController = NotificationDataController()
    
    func fetchBinDays(addressID: Int) async throws {
        if let binDays = binDaysDataController.fetchBinData() {
            self.binDays = binDays.sorted { $0.date < $1.date }
        } else {
            try await fetchDataFromTheNetwork(usingId: addressID)
        }
    }
    
    func fetchDataFromTheNetwork(usingId addressID: Int) async throws {
        self.binDays = try await binDaysDataController.fetchBinDates(id: addressID)
        let _ = await updateNotifications(binDays: binDays)
        self.binDays = binDays.sorted { $0.date < $1.date }
    }
    
    func updateNotifications(binDays: [BinDays]) async -> Bool {
        
        let notificationState = self.notificationDataController.fetchNotificationState()
        
        if let notificationState = notificationState {
            return await notificationDataController.setupBinNotification(for: binDays, at: notificationState)
        } else {
            return false
        }
    }
    
}
