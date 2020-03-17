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
        #if DEBUG
        #error("If you don't use QR Code, configuring app ID is required.")
        SendBirdCall.configure(appId: YOUR_APP_ID)
        
        if SendBirdCall.appId != nil {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            if let window = self.window {
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
                window.rootViewController = viewController
                window.makeKeyAndVisible()
            }
        }
        #endif
        SendBirdCall.addDelegate(self, identifier: "DelegateIdentification")
        
        self.voipRegistration()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
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
        SendBirdCall.registerVoIPPush(token: pushCredentials.token, unique: true) { error in
            guard error == nil else { return }
            // Even if an error occurs, SendBirdCalls will save the pushToken value and reinvoke this method internally while authenticating.
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
        // MARK: Handling incoming call
        SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type) { uuid in
            completion()
        }
    }
}
