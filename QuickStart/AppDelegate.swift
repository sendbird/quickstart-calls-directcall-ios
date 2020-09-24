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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var queue: DispatchQueue = DispatchQueue(label: "com.sendbird.calls.quickstart.appdelegate")
    var voipRegistry: PKPushRegistry?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: SendBirdCall.configure(appId:)
        // See [here](https://github.com/sendbird/quickstart-calls-ios#creating-a-sendbird-application) for the application ID.
        // SendBirdCall.configure(appId: YOUR_APP_ID)

        self.autoSignIn { error in
            if error == nil { return }
            // Show SignIn controller when failed to auto sign in
            self.window?.rootViewController?.present(UIStoryboard.signController(), animated: true, completion: nil)
        }
        
        // To process incoming call, you need to add `SendBirdCallDelegate` and implement its protocol methods.
        SendBirdCall.addDelegate(self, identifier: "com.sendbird.calls.quickstart.delegate")
        
        // To receive incoming call, you need to register VoIP push token
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
    
    // MARK: - SendBirdCall - Auto Sign In
    func autoSignIn(completionHandler: @escaping (Error?) -> Void) {
        // fetch credential
        guard let pendingCredential = UserDefaults.standard.credential else {
            DispatchQueue.main.async {
                completionHandler(CredentialErrors.empty)
            }
            return
        }
        // authenticate
        self.authenticate(with: pendingCredential, completionHandler: completionHandler)
    }
    
    func authenticate(with credential: Credential, completionHandler: @escaping (Error?) -> Void) {
        // Configure app ID before authenticate
        SendBirdCall.configure(appId: credential.appId)
        
        // Authenticate
        let authParams = AuthenticateParams(userId: credential.userId, accessToken: credential.accessToken)
        SendBirdCall.authenticate(with: authParams) { (user, error) in
            guard user != nil else {
                // Failed
                DispatchQueue.main.async {
                    completionHandler(error ?? CredentialErrors.unknown)
                }
                return
            }
            // Succeed
            let credential = Credential(accessToken: credential.accessToken)
            let credentialManager = CredentialManager.shared
            credentialManager.updateCredential(credential)
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
}
