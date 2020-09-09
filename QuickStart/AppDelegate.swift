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
        
        // To process incoming call, you need to add `SendBirdCallDelegate` and implement its protocol methods.
        SendBirdCall.addDelegate(self, identifier: "com.sendbird.calls.quickstart.delegate")
        
        self.voipRegistration()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // This method will be called when the app is forcefully terminated.
        // End all ongoing calls in this method.
        let callManager = CXCallManager.shared
        let ongoingCalls = callManager.currentCalls.compactMap { SendBirdCall.getCall(forUUID: $0.uuid) }
        
        ongoingCalls.forEach { directCall in
            // Sendbird Calls: End call
            directCall.end()
            
            // CallKit: Request End transaction
            callManager.endCXCall(directCall)
            
            // CallKit: Report End if uuid is valid
            if let uuid = directCall.callUUID {
                callManager.endCall(for: uuid, endedAt: Date(), reason: .none)
            }
        }
        // However, because iOS gives a limited time to perform remaining tasks,
        // There might be some calls failed to be ended
        // In this case, I recommend that you register local notification to notify the unterminated calls.
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

                CXCallManager.shared.reportIncomingCall(with: randomUUID, update: update) { _ in
                    CXCallManager.shared.endCall(for: randomUUID, endedAt: Date(), reason: .acceptFailed)
                }
                completion()
                return
            }

            completion()
        }
    }
}
