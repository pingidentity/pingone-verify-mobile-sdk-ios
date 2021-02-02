//
//  AppDelegate.swift
//  P1VerifyApp
//
//  Created by Ping Identity on 11/13/20.
//  Copyright © 2021 Ping Identity. All rights reserved.
//

import UIKit
import CryptoTools

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pnToken: Data?
    var notificationUserInfo: [AnyHashable: Any]? {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(StorageManager.REMOTE_PUSH_RECEIVED_NOTIFICATION_CENTER_KEY), object: nil)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.notificationUserInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any]
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken: \(deviceToken.hexDescription)")
        self.pnToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        UIApplication.shared.applicationIconBadgeNumber = 0  // clear notification badge if it's there
        print("Notification Received")
        self.notificationUserInfo = userInfo
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error: App was unable to register for remote notifications: \(error.localizedDescription)")
    }

    public class func registerForAPNS() {
        DispatchQueue.main.async {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Error: User denied permission for push notifications. \(error.localizedDescription)")
                    
                    let alert = UIAlertController(title: "Notifications Disabled".localized, message: "You must enable notifications for your application to be able to submit data for verification.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel".localized, style: UIAlertAction.Style.cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Go to Settings".localized, style: UIAlertAction.Style.default, handler: { (_) in
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                        }
                    }))
                    alert.show()
                }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
        }
    }
    
}

