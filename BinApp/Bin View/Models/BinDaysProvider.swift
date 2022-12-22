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
    let errorAlertController = ErrorAlertController()
    let notificationDataController = NotificationDataController()
    
    func fetchBinDays(addressID: Int) async throws -> [BinDays] {
        if let binDays = binDaysDataController.fetchBinData() {
            return binDays
        } else {
            let binDays = try await fetchDataFromTheNetwork(usingId: addressID)
            let _ = await updateNotifications(binDays: binDays)
            return binDays
        }
    }
    
    func fetchDataFromTheNetwork(usingId addressID: Int) async throws -> [BinDays] {
        let binDays = try await binDaysDataController.fetchBinDates(id: addressID)
        return binDays
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
