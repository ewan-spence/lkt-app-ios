//
//  AppDelegate.swift
//  Let's Keep Talking
//
//  Created by Ewan Spence on 19/09/2020.
//

import UIKit
import UserNotifications
import UserNotificationsUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// Launch application func
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            
            if let error = error {
                debugPrint(error)
                
            } else if(granted){
                
                let callBookCategory = UNNotificationCategory(
                    identifier: "CALL_BOOK",
                    actions: [UNNotificationAction(identifier: "VIEW_CALL", title: "View Call", options: UNNotificationActionOptions(rawValue: 0))],
                    intentIdentifiers: [],
                    hiddenPreviewsBodyPlaceholder: "",
                    options: .customDismissAction
                )
                
                let callCancelCategory = UNNotificationCategory(
                    identifier: "CALL_CANCEL",
                    actions: [UNNotificationAction(identifier: "DISMISS", title: "Dismiss Notification", options: UNNotificationActionOptions(rawValue: 0))],
                    intentIdentifiers: [],
                    hiddenPreviewsBodyPlaceholder: "",
                    options: .customDismissAction
                )
                
                center.setNotificationCategories([callBookCategory, callCancelCategory])
            }
        }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    /// DevToken Setting Function
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        UserDefaults.standard.setValue(deviceTokenString, forKey: "devID")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint(error)
    }
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

