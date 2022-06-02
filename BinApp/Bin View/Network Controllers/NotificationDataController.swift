//
//  NotificationDataController.swift
//  BinApp
//
//  Created by Jordan Porter on 18/04/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationDataController: NSObject, UNUserNotificationCenterDelegate {
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    public func setupBinNotification(for binDays: [BinDays], at state: BinNotifications, completion: @escaping (Bool) -> Void) {
        var notificationTimes = [String: Date]()
        
        if (state.evening) {
            notificationTimes.updateValue(state.eveningTime, forKey: "evening")
        } else {
            notificationTimes.removeValue(forKey: "evening")
        }
        
        if (state.morning) {
            notificationTimes.updateValue(state.morningTime, forKey: "morning")
        } else {
            notificationTimes.removeValue(forKey: "morning")
        }
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (didAllow, error) in
            
            if !didAllow {
                completion(false)
            } else {
                self.createNotificationForDays(binDays, at: notificationTimes, for: state.types)
                completion(true)
            }
        }
    }
    
    private func createNotificationForDays(_ binDays: [BinDays], at times: [String: Date], for types: [Int: Bool]) {
        
        notificationCenter.removeAllPendingNotificationRequests()
        
        let categoryIdentifier = "Bin Reminder"
        
        for (title, time) in times {
            
            let previousDay = title == "evening" ? true : false
            let timeComponent = Calendar.current.dateComponents([.hour, .minute], from: time)
            
            for binDay in binDays {
                for (type, isAllowed) in types {
                    if type == binDay.type.position && isAllowed {
                        let content = setNotificationContent(withcategory: categoryIdentifier, title: "Bin Day", body: "Put out \(binDay.type.description) Bin")
                        createNotification(with: content, at: timeComponent, for: binDay, previousDay: previousDay)
                    }
                }
            }
        }
    }
    
    private func createNotification(with content: UNNotificationContent, at time: DateComponents, for binDay: BinDays, previousDay: Bool) {
        
        guard var date = Calendar.current.date(byAdding: time, to: binDay.date) else { return }
        if previousDay {
            date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        }
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(dateComponents.description) \(binDay.type.description)", content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                //error handle
                print(error)
                return
            }
        }
    }
    
    private func setNotificationContent(withcategory categoryIdentifier: String, title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        content.categoryIdentifier = categoryIdentifier
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        return content
    }
    
    func saveNotificationState(_ binNottifications: BinNotifications) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("notification_data").appendingPathExtension("plist")
        
        if FileManager.default.fileExists(atPath: archiveURL.path){
            try? FileManager.default.removeItem(atPath: archiveURL.path)
        }
        
        let propertyListEncoder = PropertyListEncoder()
        let encodedLocations = try? propertyListEncoder.encode(binNottifications)
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
    
}
