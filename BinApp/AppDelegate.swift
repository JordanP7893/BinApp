//
//  AppDelegate.swift
//  BinApp
//
//  Created by Jordan Porter on 09/04/2019.
//  Copyright © 2019 Jordan Porter. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let notificationDataController = NotificationDataController()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        notificationDataController.notificationCenter.delegate = self
        
        application.registerForRemoteNotifications()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationReceived"), object: nil, userInfo: nil)
        return [.sound, .banner, .badge]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case "done":
            notificationDataController.removeDeliveredNotification(withIdentifier: response.notification.request.identifier)
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationsCleared"), object: nil, userInfo: ["id": response.notification.request.identifier])
        case "snooze10Min":
            notificationDataController.snoozeNotification(from: response.notification.request.content, withId: response.notification.request.identifier, for: 10 * 60)
        case "snooze1Hour":
            notificationDataController.snoozeNotification(from: response.notification.request.content, withId: response.notification.request.identifier, for: 60 * 60)
        case "snooze2Hour":
            notificationDataController.snoozeNotification(from: response.notification.request.content, withId: response.notification.request.identifier, for: 2 * 60 * 60)
        case "tonight":
            notificationDataController.remindTonightNotification(from: response.notification.request.content, withId: response.notification.request.identifier)
        default:
            if response.notification.request.content.categoryIdentifier == "InfoNotifications" {
                guard let userInfo = response.notification.request.content.userInfo as NSDictionary as? [String: NSObject] else { return }
                if let ck = userInfo["ck"] as? [String: Any] {
                    if let qry = ck["qry"] as? [String: Any] {
                        if let af = qry["af"] as? [String: Any] {
                            if let path = af["path"] as? String {
                                guard let tabBarController = self.window?.rootViewController as? UITabBarController else { return }
                                tabBarController.selectedIndex = 1
                                guard let navigationController = tabBarController.viewControllers?[1] as? UINavigationController,
                                        let mapViewController = navigationController.viewControllers.first as? MapViewController else {
                                    return
                                }
                                
                                mapViewController.notificationTappedWithRecyclingType(path)
                            }
                        }
                    }
                }
            } else {
                guard let tabBarController = self.window?.rootViewController as? UITabBarController else { return }
                tabBarController.selectedIndex = 0
                
                guard let navigationController = tabBarController.viewControllers?.first as? UINavigationController,
                        let binTableViewController = navigationController.viewControllers.first as? BinDayTableViewController else {
                    return
                }
                
                let id = response.notification.request.identifier
                binTableViewController.notificationTapped(withId: id)
            }
        }
        completionHandler()
    }
}
