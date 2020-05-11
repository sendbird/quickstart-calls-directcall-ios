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
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var queue: DispatchQueue = DispatchQueue(label: "com.sendbird.calls.quickstart.appdelegate")
    var voipRegistry: PKPushRegistry?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: SendBirdCall.configure(appId:)
        // See [here](https://github.com/sendbird/quickstart-calls-ios#creating-a-sendbird-application) for the application ID.
        // SendBirdCall.configure(appId: YOUR_APP_ID)

        if SendBirdCall.appId != nil {
            // User ID Mode
            self.window = UIWindow(frame: UIScreen.main.bounds)
            guard let window = self.window else { return false }
            window.rootViewController = UIStoryboard.signController()
            window.makeKeyAndVisible()
        } else if let appId = UserDefaults.standard.appId {
            // QR Code Mode
            SendBirdCall.configure(appId: appId)
        }
        
        // You must call `SendBirdCall.addDelegate(_:identifier:)` right after configuring new app ID
        SendBirdCall.addDelegate(self, identifier: "com.sendbird.calls.quickstart.delegate")
        
        self.voipRegistration()
        
        return true
    }
}

extension AppDelegate: PKPushRegistryDelegate {
    func voipRegistration() {
        self.voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        self.voipRegistry?.delegate = self
        self.voipRegistry?.desiredPushTypes = [.voIP]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        //
    }
    
    // MARK: SendBirdCalls - Registering push token.
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        UserDefaults.standard.voipPushToken = pushCredentials.token
        print("Push token is \(pushCredentials.token.toHexString())")
        
        SendBirdCall.registerVoIPPush(token: pushCredentials.token, unique: true) { error in
            guard error == nil else { return }
            // Even if an error occurs, SendBirdCalls will save the pushToken value and reinvoke this method internally while authenticating.
        }
    }
    
    // MARK: SendBirdCalls - Receive incoming push event
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type, completionHandler: nil)
    }
    
    // Handle Incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        // MARK: Handling incoming call
        SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type) { uuid in
            guard uuid != nil else {
                let update = CXCallUpdate()
                update.remoteHandle = CXHandle(type: .generic, value: "invalid")
                let randomUUID = UUID()

                CXCallManager.shared.reportIncomingCall(with: randomUUID, update: update) { error in
                    CXCallManager.shared.endCall(for: randomUUID, endedAt: Date(), reason: .acceptFailed)
                }
                completion()
                return
            }

            completion()
        }
    }
}
