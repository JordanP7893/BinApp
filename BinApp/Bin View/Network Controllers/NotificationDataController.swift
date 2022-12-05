//
//  NotificationDataController.swift
//  BinApp
//
//  Created by Jordan Porter on 18/04/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationDataController: NSObject {
    
    let binDaysDataController = BinDaysDataController()
    private let notificationCenter = UNUserNotificationCenter.current()
    public var tappedNotificationId: String?
    
    public func getTriggeredNotifications(binDays: [BinDays],completion: @escaping  ([BinDays]?) -> Void) {
        var binDays = binDays
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (didAllow, error) in
            
            if !didAllow {
                completion(nil)
            } else {
                //Set bin state for all delivered notifications since the app was last opened
                self.notificationCenter.getDeliveredNotifications { notifications in
                    for notification in notifications {
                        if let index = binDays.firstIndex(where: {$0.id == notification.request.identifier}) {
                            binDays[index].isPending = true
                        }
                    }
                    self.binDaysDataController.saveBinData(binDays)
                    completion(binDays)
                }
            }
        }
    }
    
    public func getTappedNotification(binDays: [BinDays]) -> [BinDays] {
        var binDays = binDays
        
        //Set bin state for any tapped notifications
        if let index = binDays.firstIndex(where: {$0.id == self.tappedNotificationId}) {
            binDays[index].isPending = true
        }
        
        return binDays
    }
    
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
                self.notificationCenter.delegate = self
                self.createNotificationForDays(binDays, at: notificationTimes, for: state.types)
                completion(true)
            }
        }
    }
    
    private func createNotificationForDays(_ binDays: [BinDays], at times: [String: Date], for types: [Int: Bool]) {
        
        notificationCenter.removeAllPendingNotificationRequests()
        
        for (title, time) in times {
            
            let previousDay = title == "evening" ? true : false
            let timeComponent = Calendar.current.dateComponents([.hour, .minute], from: time)
            
//            var binDays = binDays
//            createTestNotification(for: binDays[0])
//            binDays.remove(at: 0)
            
            for binDay in binDays {
                for (type, isAllowed) in types {
                    if type == binDay.type.position && isAllowed {
                        createNotification(at: timeComponent, for: binDay, previousDay: previousDay)
                    }
                }
            }
        }
    }
    
//    private func createTestNotification(for binDay: BinDays) {
//        let content = setNotificationContent(withCategory: "Bin Reminder", title: "Bin Day", body: "Put out \(binDay.type.description) Bin")
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
//
//        let request = UNNotificationRequest(identifier: binDay.id, content: content, trigger: trigger)
//
//        notificationCenter.add(request) { (error) in
//            if let error = error {
//                //error handle
//                print(error)
//                return
//            }
//        }
//    }
    
    private func createNotification(at time: DateComponents, for binDay: BinDays, previousDay: Bool) {
        let content = setNotificationContent(withCategory: "Bin Reminder", title: "Bin Day", body: "Put out \(binDay.type.description) Bin")
        
        guard var date = Calendar.current.date(byAdding: time, to: binDay.date) else { return }
        if previousDay {
            date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        }
        
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
    
}

extension NotificationDataController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationReceived"), object: nil, userInfo: nil)
        return [.sound, .banner]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let id = response.notification.request.identifier
        tappedNotificationId = id
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationTapped"), object: nil, userInfo: nil)
    }
}
