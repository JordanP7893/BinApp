//
//  NotificationService.swift
//  BinApp
//
//  Created by Jordan Porter on 18/04/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation
import UserNotifications

protocol UserNotificationProtocol {
    func setupBinNotification(for binDays: [BinDays], at state: BinNotifications) async throws
    
    func markBinDone(id: String)
    func snooze(_ bin: BinDays, for time: TimeInterval, isMorning: Bool)
    func snoozeUntilTonight(_ bin: BinDays)
}

// MARK: Notification setup methods

class UserNotificationService: UserNotificationProtocol {
    
    private let binDaysDataService: BinDaysDataService
    public let notificationCenter = UNUserNotificationCenter.current()
    
    init(binDaysDataService: BinDaysDataService) {
        self.binDaysDataService = binDaysDataService
    }
    
    public func setupBinNotification(for binDays: [BinDays], at state: BinNotifications) async throws {
        let isAuthorized = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        if isAuthorized {
            registerActions()
            notificationCenter.removeAllPendingNotificationRequests()
            notificationCenter.removeAllDeliveredNotifications()
            await resetBadge()
            
            for binDay in binDays {
                try await createNotification(for: binDay)
            }
        }
    }
    
    private func createNotification(for binDay: BinDays) async throws {
        if let notificationEvening = binDay.notificationEvening {
            let categoryIdentifier: NotificationCategoryIdentifier = Calendar.current.component(.hour, from: notificationEvening) < NotificationConstants.eveningHourThreshold ? .eveningWithTonight : .evening
            try await createNotification(for: binDay, at: notificationEvening, withCategoryIdentifier: categoryIdentifier)
        }
        if let notificationMorning = binDay.notificationMorning {
            try await createNotification(for: binDay, at: notificationMorning, withCategoryIdentifier: .morning)
        }
    }
    
    private func createNotification(for binDay: BinDays, at date: Date, withCategoryIdentifier categoryIdentifier: NotificationCategoryIdentifier) async throws {
        let content = binDayNotificationContent(for: binDay, category: categoryIdentifier)
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: binDay.id, content: content, trigger: trigger)
        
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
    
    private func registerActions() {
        let doneIcon = UNNotificationActionIcon(systemImageName: "checkmark.square")
        let snoozeIcon = UNNotificationActionIcon(systemImageName: "alarm")
        let tonightIcon = UNNotificationActionIcon(systemImageName: "moon.zzz")
        
        let doneAction = UNNotificationAction(identifier: "done", title: "Done", icon: doneIcon)
        let snooze10MinAction = UNNotificationAction(identifier: "snooze10Min", title: "Remind me in 10 minutes", icon: snoozeIcon)
        let snooze1HourAction = UNNotificationAction(identifier: "snooze1Hour", title: "Remind me in 1 hour", icon: snoozeIcon)
        let snooze2HourAction = UNNotificationAction(identifier: "snooze2Hour", title: "Remind me in 2 hours", icon: snoozeIcon)
        let tonightAction = UNNotificationAction(identifier:"tonight", title: "Remind me tonight", icon: tonightIcon)
        
        let morningCategory = UNNotificationCategory(identifier: NotificationCategoryIdentifier.morning.rawValue, actions: [doneAction, snooze10MinAction, snooze1HourAction, snooze2HourAction], intentIdentifiers: [])
        let eveningCategory = UNNotificationCategory(identifier: NotificationCategoryIdentifier.evening.rawValue, actions: [doneAction, snooze10MinAction, snooze1HourAction, snooze2HourAction], intentIdentifiers: [])
        let eveningWithTonightCategory = UNNotificationCategory(identifier: NotificationCategoryIdentifier.eveningWithTonight.rawValue, actions: [doneAction, snooze10MinAction, snooze1HourAction, tonightAction], intentIdentifiers: [])
        
        notificationCenter.setNotificationCategories([morningCategory, eveningCategory, eveningWithTonightCategory])
    }
}

// MARK: Notification update methods

extension UserNotificationService {
    func markBinDone(id: String) {
        removeDeliveredNotification(withIdentifier: id)
        try? binDaysDataService.markAsDoneFor(bin: id)
    }
    
    private func removeDeliveredNotification(withIdentifier id: String) {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
        Task {
            await resetBadge()
        }
    }
    
    public func snooze(_ bin: BinDays, for time: TimeInterval, isMorning: Bool = false) {
        var categoryIdentifier: NotificationCategoryIdentifier
        if isMorning {
            categoryIdentifier = .morning
        } else {
            categoryIdentifier = .evening
        }
        
        let content = binDayNotificationContent(for: bin, category: categoryIdentifier)
        
        snoozeNotification(from: content, withId: bin.id, for: time)
    }
    
    public func snoozeUntilTonight(_ bin: BinDays) {
        let content = binDayNotificationContent(for: bin, category: .evening)
        
        remindTonight(from: content, withId: bin.id)
    }
    
    public func snoozeNotification(from content: UNNotificationContent, withId id: String, for snoozeTime: TimeInterval) {
        let intervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: snoozeTime, repeats: false)
        
        let newContent = content.mutableCopy() as! UNMutableNotificationContent
        if Calendar.current.component(.hour, from: Date()) > NotificationConstants.eveningHourThreshold && content.categoryIdentifier == NotificationCategoryIdentifier.eveningWithTonight.rawValue {
            newContent.categoryIdentifier = NotificationCategoryIdentifier.evening.rawValue
        } else {
            newContent.categoryIdentifier = content.categoryIdentifier
        }
        
        copyNotification(from: newContent, withId: id, withTrigger: intervalTrigger)
        
        let newNotificationDate = Calendar.current.date(byAdding: .second, value: Int(snoozeTime), to: Date())!
        try? binDaysDataService.updateBinDateFor(
            bin: id,
            to: newNotificationDate,
            isMorningDate: newContent.categoryIdentifier == NotificationCategoryIdentifier.morning.rawValue
        )
    }
    
    public func remindTonight(from content: UNNotificationContent, withId id: String) {
        
        //Only snooze for tonight if before evening threshold, else just delay for 1 hour
        guard Calendar.current.component(.hour, from: Date()) < NotificationConstants.eveningHourThreshold else {
            snoozeNotification(from: content, withId: id, for: NotificationConstants.oneHour)
            return
        }
        
        let todaysDate = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let eveningTime = DateComponents(hour: NotificationConstants.eveningHourThreshold + 1)
        
        let triggerDateTime = DateComponents(year: todaysDate.year, month: todaysDate.month, day: todaysDate.day, hour: eveningTime.hour, minute: eveningTime.minute)
        let tonightTrigger = UNCalendarNotificationTrigger(dateMatching: triggerDateTime, repeats: false)
        
        let newContent = content.mutableCopy() as! UNMutableNotificationContent
        newContent.categoryIdentifier = NotificationCategoryIdentifier.evening.rawValue
        
        copyNotification(from: newContent, withId: id, withTrigger: tonightTrigger)
        guard let tonightDate = Calendar.current.date(from: triggerDateTime) else { return }
        try? binDaysDataService.updateBinDateFor(
            bin: id,
            to: tonightDate,
            isMorningDate: false
        )
    }
    
    private func copyNotification(from content: UNNotificationContent, withId id: String, withTrigger trigger: UNNotificationTrigger) {
        removeDeliveredNotification(withIdentifier: id)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
}

// MARK: Helpers

extension UserNotificationService {
    private func binDayNotificationContent(for bin: BinDays, category: NotificationCategoryIdentifier) -> UNMutableNotificationContent {
        return setNotificationContent(
            withCategory: category.rawValue,
            title: "Bin Day",
            body: "Put out \(bin.type.description) Bin"
        )
    }
    
    private enum NotificationCategoryIdentifier: String {
        case evening
        case eveningWithTonight
        case morning
    }
    
    private enum NotificationConstants {
        static let eveningHourThreshold = 18
        static let tonightHour = 19
        static let oneHour: TimeInterval = 60 * 60
    }
    
    private func resetBadge() async {
        try? await notificationCenter.setBadgeCount(0)
    }
}

final class MockUserNotificationService: UserNotificationProtocol {
    func setupBinNotification(for binDays: [BinDays], at state: BinNotifications) async throws {}
    
    func markBinDone(id: String) {}
    func snooze(_ bin: BinDays, for time: TimeInterval, isMorning: Bool) {}
    func snoozeUntilTonight(_ bin: BinDays) {}
}
