//
//  AppDelegate.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import CallKit
import PushKit
import SendBirdCalls
import UserNotifications
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var queue: DispatchQueue = DispatchQueue(label: "com.sendbird.quickstart.voicevideo.appdelegate")
    var voipRegistry: PKPushRegistry?
    
    lazy var provider: CXProvider = {
        let provider = CXProvider.default
        provider.setDelegate(self, queue: .main)
        return provider
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: SendBirdCall.configure(appId:)
        // See [here](https://github.com/sendbird/quickstart-calls-ios#creating-a-sendbird-application) for the application ID.
        SendBirdCall.configure(appId: YOUR_APP_ID)
        
        SendBirdCall.addDelegate(self, identifier: "DelegateIdentification")
        
        // Set up notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else { return }
            self.getNotificationSettings()
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate: PKPushRegistryDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.voipRegistration()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func voipRegistration() {
        self.voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        self.voipRegistry?.delegate = self
        self.voipRegistry?.desiredPushTypes = [.voIP]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {

    }
    
    // MARK: SendBirdCalls - Registering push token.
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        SendBirdCall.register(pushToken: pushCredentials.token, unique: true) { error in
            guard error == nil else { return }
            // Even error is ocurred, SendBirdCalls will have pushToken value. This method will be invoked again while authenticating.
        }
        UserDefaults.standard.pushToken = pushCredentials.token
        
        print("Push token is \(pushCredentials.token.toHexString())")
    }
    
    
    // MARK: SendBirdCalls - Receive incoming push event
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type, completionHandler: nil)
    }
    
    // Handle Incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        SendBirdCall.addDelegate(self, identifier: "DelegateIdentification")
        
        // MARK: Handling incoming call
        SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type) { uuid in
            guard let uuid = uuid else { return }
            
            if CXCallControllerManager.sharedController.callObserver.calls.isEmpty { // Should be cross-checked with state to prevent weird event processings
                
                // Use CXProvider to report the incoming call to the system
                // Construct a CXCallUpdate describing the incoming call, including the caller.
                let name = ""
                let update = CXCallUpdate()
                update.remoteHandle = CXHandle(type: .generic, value: name)
                update.hasVideo = false
                
                // Report the incoming call to the system
                self.provider.reportNewIncomingCall(with: uuid, update: update) { error in
                    if error == nil {
                        // success
                    }
                    
//                    self.provider.reportCall(with: uuid, updated: update)
                    completion()
                }
            }
        }
    }
}

extension AppDelegate {
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) { }
}

