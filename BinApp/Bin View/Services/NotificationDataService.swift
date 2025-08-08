//
//  NotificationDataService.swift
//  BinApp
//
//  Created by Jordan Porter on 11/07/2025.
//  Copyright © 2025 Jordan Porter. All rights reserved.
//

import Foundation

protocol NotificationDataProtocol {
    func saveNotificationState(_ binNotifications: BinNotifications) throws
    func fetchNotificationState() -> BinNotifications
}

class NotificationDataService: NotificationDataProtocol {
    
    let archivingService: ArchivingService
    
    init(archivingService: ArchivingService = DefaultArchivingService()) {
        self.archivingService = archivingService
    }
    
    func saveNotificationState(_ binNotifications: BinNotifications) throws {
        try archivingService.save(binNotifications, to: archiveUrl)
    }
    
    func fetchNotificationState() -> BinNotifications {
        do {
            return try archivingService.load(from: archiveUrl, as: BinNotifications.self)
        } catch {
            do {
                let legacyNotifications = try fetchLegacyNotificationState()
                return legacyNotifications
            } catch {
                return .init()
            }
        }
    }
}

extension NotificationDataService {
    private enum ArchiveNames {
        static let current = "notification_data_v2"
        static let legacy = "notification_data"
    }

    private var archiveUrl: URL {
        archivingService.getArchiveUrl(withName: ArchiveNames.current)
    }
    
    private func fetchLegacyNotificationState() throws -> BinNotifications {
        let legacyArchiveUrl = archivingService.getArchiveUrl(withName: "notification_data")
        let legacyNotifications = try archivingService.load(from: legacyArchiveUrl, as: LegacyBinNotifications.self)
        
        let decodedNotifications = BinNotifications.init(fromLegacy: legacyNotifications)
        
        try saveNotificationState(decodedNotifications)
        
        if FileManager.default.fileExists(atPath: legacyArchiveUrl.path){
            try? FileManager.default.removeItem(atPath: legacyArchiveUrl.path)
        }
        
        return decodedNotifications
    }
}

final class MockNotificationDataService: NotificationDataProtocol {
    func saveNotificationState(_ binNotifications: BinNotifications) {}
    
    func fetchNotificationState() -> BinNotifications {
        BinNotifications(morningTime: nil, eveningTime: .distantPast, types: [.black, .green])
    }
}
