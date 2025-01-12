//
//  NotificationDataController.swift
//  BinApp
//
//  Created by Jordan Porter on 18/04/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation
import UserNotifications

protocol NotificationDataProtocol {
    func setupBinNotification(for binDays: [BinDays], at state: BinNotifications) async throws
    func saveNotificationState(_ binNotifications: BinNotifications) throws
    func fetchNotificationState() throws -> BinNotifications
}

class NotificationDataController: NotificationDataProtocol {
    
    public let notificationCenter = UNUserNotificationCenter.current()
    
    public func setupBinNotification(for binDays: [BinDays], at state: BinNotifications) async throws {
        let isAuthorized = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        if isAuthorized {
            registerActions()
            Task {
                notificationCenter.setBadgeCount(0)
            }
            notificationCenter.removeAllPendingNotificationRequests()
            notificationCenter.removeAllDeliveredNotifications()
            
            for binDay in binDays {
                try await createNotification(for: binDay)
            }
        }
    }
    
    private func createNotification(for binDay: BinDays) async throws {
        if let notificationEvening = binDay.notificationEvening {
            var categoryIdentifier = NotificationCategoryIdentifier.standard
            if Calendar.current.component(.hour, from: notificationEvening) < 18 {
                categoryIdentifier = NotificationCategoryIdentifier.tonight
            }
            let content = setNotificationContent(withCategory: categoryIdentifier.rawValue, title: "Bin Day", body: "Put out \(binDay.type.description) Bin")
            try await createNotification(id: binDay.id, at: notificationEvening, withContent: content)
        } else if let notificationMorning = binDay.notificationMorning {
            let categoryIdentifier = NotificationCategoryIdentifier.tonight
            let content = setNotificationContent(withCategory: categoryIdentifier.rawValue, title: "Bin Day", body: "Put out \(binDay.type.description) Bin")
            try await createNotification(id: binDay.id, at: notificationMorning, withContent: content)
        }
    }
    
    private func createNotification(id: String, at date: Date, withContent content: UNMutableNotificationContent) async throws {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        try await notificationCenter.add(request)
    }
    
    private func setNotificationContent(withCategory categoryIdentifier: String, title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        content.categoryIdentifier = categoryIdentifier
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        return content
    }
    
    func saveNotificationState(_ binNotifications: BinNotifications) throws {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("notification_data_v2").appendingPathExtension("plist")
        
        if FileManager.default.fileExists(atPath: archiveURL.path){
            try? FileManager.default.removeItem(atPath: archiveURL.path)
        }
        
        let propertyListEncoder = PropertyListEncoder()
        let encodedLocations = try propertyListEncoder.encode(binNotifications)
        try encodedLocations.write(to: archiveURL, options: .noFileProtection)
    }
    
    func fetchNotificationState() throws -> BinNotifications {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("notification_data_v2").appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        let retrievedLocations = try Data(contentsOf: archiveURL)
        let decodedNotifications = try propertyListDecoder.decode(BinNotifications.self, from: retrievedLocations)
            
        return decodedNotifications
    }
    
    public func removeDeliveredNotification(withIdentifier id: String) {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
        Task {
            notificationCenter.setBadgeCount(0)
        }
    }
    
    public func snoozeBin(_ bin: BinDays, for time: TimeInterval) {
        let content = setNotificationContent(withCategory: NotificationCategoryIdentifier.standard.rawValue, title: "Bin Day", body: "Put out \(bin.type.description) Bin")
        
        snoozeNotification(from: content, withId: bin.id, for: time)
    }
    
    public func tonightBin(_ bin: BinDays) {
        let content = setNotificationContent(withCategory: NotificationCategoryIdentifier.standard.rawValue, title: "Bin Day", body: "Put out \(bin.type.description) Bin")
        
        remindTonightNotification(from: content, withId: bin.id)
    }
    
    public func snoozeNotification(from content: UNNotificationContent, withId id: String, for snoozeTime: TimeInterval) {
        let intervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: snoozeTime, repeats: false)
        
        let newContent = content.mutableCopy() as! UNMutableNotificationContent
        
        if let notificationDueDateTime = Calendar.current.date(byAdding: .second, value: Int(snoozeTime), to: Date()) {
            
            let todaysDate = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            let sixEveningTime = DateComponents(hour: 18, minute: 0)
            let sixTonightComponents = DateComponents(year: todaysDate.year, month: todaysDate.month, day: todaysDate.day, hour: sixEveningTime.hour, minute: sixEveningTime.minute)
            
            if let sixTonightDateTime = Calendar.current.date(from: sixTonightComponents), notificationDueDateTime > sixTonightDateTime {
                newContent.categoryIdentifier = NotificationCategoryIdentifier.standard.rawValue
            }
        }
        
        copyNotification(from: newContent, withId: id, withTrigger: intervalTrigger)
    }
    
    public func remindTonightNotification(from content: UNNotificationContent, withId id: String) {
        
        //Only snooze for tonight if before 18:00, else just delay for 1 hour
        guard Calendar.current.component(.hour, from: Date()) < 18 else {
            snoozeNotification(from: content, withId: id, for: 60 * 60)
            return
        }
        
        let todaysDate = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let sevenEveningTime = DateComponents(hour: 19, minute: 0)
        
        let triggerDateTime = DateComponents(year: todaysDate.year, month: todaysDate.month, day: todaysDate.day, hour: sevenEveningTime.hour, minute: sevenEveningTime.minute)
        let tonightTrigger = UNCalendarNotificationTrigger(dateMatching: triggerDateTime, repeats: false)
        
        let newContent = content.mutableCopy() as! UNMutableNotificationContent
        newContent.categoryIdentifier = NotificationCategoryIdentifier.standard.rawValue
        
        copyNotification(from: newContent, withId: id, withTrigger: tonightTrigger)
    }
    
    private func copyNotification(from content: UNNotificationContent, withId id: String, withTrigger trigger: UNNotificationTrigger) {
        removeDeliveredNotification(withIdentifier: id)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
    
    private func registerActions() {
        let doneIcon = UNNotificationActionIcon(systemImageName: "checkmark.square")
        let snoozeIcon = UNNotificationActionIcon(systemImageName: "alarm")
        let tonightIcon = UNNotificationActionIcon(systemImageName: "moon.zzz")
        
        let doneAction = UNNotificationAction(identifier: "done", title: "Done", icon: doneIcon)
        let snooze10MinAction = UNNotificationAction(identifier: "snooze10Min", title: "Remind me in 10 minutes", icon: snoozeIcon)
        let snooze1HourAction = UNNotificationAction(identifier: "snooze1Hour", title: "Remind me in 1 hour", icon: snoozeIcon)
        let snooze2HourAction = UNNotificationAction(identifier: "snooze2Hour", title: "Remind me in 2 hours", icon: snoozeIcon)
        let tonightAction = UNNotificationAction(identifier:"tonight", title: "Remind me tonight", icon: tonightIcon)
        
        let snoozeCategory = UNNotificationCategory(identifier: NotificationCategoryIdentifier.standard.rawValue, actions: [doneAction, snooze10MinAction, snooze1HourAction, snooze2HourAction], intentIdentifiers: [])
        let tonightCategory = UNNotificationCategory(identifier: NotificationCategoryIdentifier.tonight.rawValue, actions: [doneAction, snooze10MinAction, snooze1HourAction, tonightAction], intentIdentifiers: [])
        
        notificationCenter.setNotificationCategories([snoozeCategory, tonightCategory])
    }
}

enum NotificationCategoryIdentifier: String {
    case standard
    case tonight
}

class MockNotificationDataController: NotificationDataProtocol {
    func setupBinNotification(for binDays: [BinDays], at state: BinNotifications) async throws {}
    
    func saveNotificationState(_ binNotifications: BinNotifications) {}
    
    func fetchNotificationState() throws -> BinNotifications {
        BinNotifications(morningTime: nil, eveningTime: .distantPast, types: [.black, .green])
    }
}
