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
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            window.rootViewController = viewController
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
    
    // To make an outgoing call from url, you need to implement this method
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let calleeId = url.calleeId else { return false }
        
        let callOption = CallOptions()
        let dialParams = DialParams(calleeId: calleeId, isVideoCall: false, callOptions: callOption, customItems: [:])
        SendBirdCall.dial(with: dialParams) { call, error in
            guard let call = call, error == nil else { return }
            let handle = CXHandle(type: .generic, value: calleeId)
            
            let startCallAction = CXStartCallAction(call: call.callUUID!, handle: handle)
            startCallAction.isVideo = call.isVideoCall
            
            let transaction = CXTransaction(action: startCallAction)
            
            CXCallControllerManager.shared.requestTransaction(transaction, action: "SendBird - Start Call")
        }
        return true
    }
    
    // To make an outgoing call from native call logs, so called "Recents" in iPhone, you need to implement this method and add IntentExtension as a new target.
    // Please refer to IntentHandler (path: ~/QuickStartIntent/IntentHandler.swift)
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let calleeId = userActivity.calleeId else {
            showError(with: "Could not determine callee ID")
            return false
        }

        guard let video = userActivity.video else {
            showError(with: "Could not determine video from call log")
            return false
        }

        let callOption = CallOptions(isAudioEnabled: true, isVideoEnabled: video, localVideoView: nil, remoteVideoView: nil, useFrontCamera: true)
        let dialParams = DialParams(calleeId: calleeId, isVideoCall: video, callOptions: callOption, customItems: [:])
        SendBirdCall.dial(with: dialParams) { call, error in
            guard let call = call, error == nil else {
                DispatchQueue.main.async { [ weak self] in
                    guard let self = self else { return }
                    self.showError(with: error?.localizedDescription ?? "Failed to call with unknown error")
                }
                return
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.showCallView(call, hasVideo: call.isVideoCall)
            }
        }
        return true
    }
    
    private func showCallView(_ call: DirectCall, hasVideo: Bool) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: call.isVideoCall ? "VideoCallViewController" : "VoiceCallViewController")

        if var dataSource = viewController as? DirectCallDataSource {
            dataSource.call = call
            dataSource.isDialing = true
        }
        
        if let topViewController = UIViewController.topViewController {
            topViewController.present(viewController, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        }
    }
    
    private func showError(with message: String) {
        if let topViewController = UIViewController.topViewController {
            topViewController.presentErrorAlert(message: message)
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.presentErrorAlert(message: message)
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        }
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
                CXCallControllerManager.shared.reportIncomingCall(with: randomUUID, update: update) { error in
                    CXCallControllerManager.shared.endCall(for: randomUUID, endedAt: Date(), reason: .failed)
                }
                completion()
                return
            }

            completion()
        }
    }
}
