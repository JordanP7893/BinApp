//
//  NotificationDataController.swift
//  BinApp
//
//  Created by Jordan Porter on 18/04/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

protocol NotificationDataProtocol {
    func saveNotificationState(_ binNotifications: BinNotifications)
    func fetchNotificationState() -> BinNotifications?
}

class NotificationDataController: NotificationDataProtocol {
    
    public let notificationCenter = UNUserNotificationCenter.current()
    
    public func getTriggeredNotifications(binDays: [BinDays]) async -> [BinDays] {
        var binDays = binDays
        
        let deliveredNotifications = await notificationCenter.deliveredNotifications()
        for notification in deliveredNotifications {
            if let index = binDays.firstIndex(where: {$0.id == notification.request.identifier}) {
                binDays[index].isPending = true
            }
        }
        
        return binDays
    }
    
    public func setupBinNotification(for binDays: [BinDays], at state: BinNotifications) async {
//        var notificationTimes = [String: Date]()
//        
//        if (state.evening) {
//            notificationTimes.updateValue(state.eveningTime, forKey: "evening")
//        } else {
//            notificationTimes.removeValue(forKey: "evening")
//        }
//        
//        if (state.morning) {
//            notificationTimes.updateValue(state.morningTime, forKey: "morning")
//        } else {
//            notificationTimes.removeValue(forKey: "morning")
//        }
//        
//        do {
//            let isAuthorized = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
//            if isAuthorized {
//                registerActions()
//                createNotificationForDays(binDays, at: notificationTimes, for: state.types)
//                return true
//            } else {
//                return false
//            }
//        } catch {
//            return false
//        }
    }
    
    private func createNotificationForDays(_ binDays: [BinDays], at times: [String: Date], for types: [Int: Bool]) {
        
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        
        for (title, time) in times {
            
            let previousDay = title == "evening" ? true : false
            let timeComponent = Calendar.current.dateComponents([.hour, .minute], from: time)
            
//            var binDays = binDays
//            createTestNotification(for: binDays[0])
//            binDays.remove(at: 0)
            
            for binDay in binDays {
                for (type, isAllowed) in types {
//                    if type == binDay.type.position && isAllowed {
//                        createNotification(at: timeComponent, for: binDay, previousDay: previousDay)
//                    }
                }
            }
        }
    }
    
    private func createTestNotification(for binDay: BinDays) {
        let content = setNotificationContent(withCategory: NotificationCategoryIdentifier.tonight.rawValue, title: "Bin Day", body: "Put out \(binDay.type.description) Bin")

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

        let request = UNNotificationRequest(identifier: binDay.id, content: content, trigger: trigger)

        notificationCenter.add(request) { (error) in
            if let error = error {
                //error handle
                print(error)
                return
            }
        }
    }
    
    private func createNotification(at time: DateComponents, for binDay: BinDays, previousDay: Bool) {
    
        var categoryIdentifier = NotificationCategoryIdentifier.standard.rawValue
        
        guard var date = Calendar.current.date(byAdding: time, to: binDay.date) else { return }
        if previousDay {
            date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
            
            if let hour = time.hour, hour < 18 {
                categoryIdentifier = NotificationCategoryIdentifier.tonight.rawValue
            }
        }
        
        let content = setNotificationContent(withCategory: categoryIdentifier, title: "Bin Day", body: "Put out \(binDay.type.description) Bin")
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: binDay.id, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                //error handle
                print(error)
                return
            }
        }
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
    
    func saveNotificationState(_ binNotifications: BinNotifications) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("notification_data").appendingPathExtension("plist")
        
        if FileManager.default.fileExists(atPath: archiveURL.path){
            try? FileManager.default.removeItem(atPath: archiveURL.path)
        }
        
        let propertyListEncoder = PropertyListEncoder()
        let encodedLocations = try? propertyListEncoder.encode(binNotifications)
        try? encodedLocations?.write(to: archiveURL, options: .noFileProtection)
    }
    
    func fetchNotificationState() -> BinNotifications? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("notification_data").appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedLocations = try? Data(contentsOf: archiveURL), let decodedNotifications = try? propertyListDecoder.decode(BinNotifications.self, from: retrievedLocations){
            return decodedNotifications
        } else {
            return nil
        }
    }
    
    public func removeDeliveredNotification(withIdentifier id: String) {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
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
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationsCleared"), object: nil, userInfo: ["id": id])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
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
    func saveNotificationState(_ binNotifications: BinNotifications) {}
    
    func fetchNotificationState() -> BinNotifications? {
        BinNotifications(morningTime: nil, eveningTime: .distantPast, types: [.black, .green])
    }
}
