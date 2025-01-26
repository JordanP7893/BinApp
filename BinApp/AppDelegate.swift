//
//  AppDelegate.swift
//  BinApp
//
//  Created by Jordan Porter on 09/04/2019.
//  Copyright © 2019 Jordan Porter. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var app: BinApp? {
        didSet {
            if let app, let storedBinID {
                navigateToBin(binID: storedBinID, on: app)
            }
        }
    }
    var storedBinID: String? = nil
    
    var binDaysDataController: BinDaysDataController
    var notificationDataController: NotificationDataController
    
    override init() {
        self.binDaysDataController = BinDaysDataController()
        self.notificationDataController = NotificationDataController(binDaysDataController: binDaysDataController)
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        notificationDataController.notificationCenter.delegate = self
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.sound, .banner, .badge]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case "done":
            notificationDataController.markBinDone(binId: response.notification.request.identifier)
        case "snooze10Min":
            notificationDataController.snoozeNotification(
                from: response.notification.request.content,
                withId: response.notification.request.identifier,
                for: 10 * 60
            )
        case "snooze1Hour":
            notificationDataController.snoozeNotification(
                from: response.notification.request.content,
                withId: response.notification.request.identifier,
                for: 60 * 60
            )
        case "snooze2Hour":
            notificationDataController.snoozeNotification(
                from: response.notification.request.content,
                withId: response.notification.request.identifier,
                for: 2 * 60 * 60
            )
        case "tonight":
            notificationDataController.remindTonightNotification(
                from: response.notification.request.content,
                withId: response.notification.request.identifier
            )
        default:
            let id = response.notification.request.identifier
            if let app {
                navigateToBin(binID: id, on: app)
            } else {
                storedBinID = id
            }
        }
        completionHandler()
    }
    
    @MainActor
    func navigateToBin(binID: String, on app: BinApp) {
        app.tabSelection = .binList
        app.selectBinID = binID
    }
}
