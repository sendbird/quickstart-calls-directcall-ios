//
//  AppDelegate+RemotePush.swift
//  QuickStart
//
//  Created by Minhyuk Kim on 2020/05/11.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import UserNotifications
import SendBirdCalls

// MARK: - Remote Notification
extension AppDelegate {
    func remoteNotificationsRegistration(_ application: UIApplication) {
        application.registerForRemoteNotifications()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            guard error == nil else {
                print("Error while requesting permission for notifications.")
                return
            }
            
            // If success is true, the permission is given and notifications will be delivered.
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Check your app's configurations for APNs.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UserDefaults.standard.remotePushToken = deviceToken
        SendBirdCall.registerRemotePush(token: deviceToken) { error in
            print("Remote Notifications Device token is \(deviceToken.toHexString())")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if userInfo.keys.contains("sendbird_call") { // This is not necessary; SendBirdCall will not process and invoke the completionHandler for payloads that don't contain the key "sendbird_calls".
            SendBirdCall.application(application, didReceiveRemoteNotification: userInfo)
        }
    }
}
