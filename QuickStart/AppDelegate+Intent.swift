//
//  AppDelegate+Intent.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/08.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import CallKit
import SendBirdCalls

// This extension is for outgoing call from outside the app.
extension AppDelegate {
    
    // MARK: - From Native Call Logs
    // To make an outgoing call from native call logs, so called "Recents" in iPhone, you need to implement this method and add IntentExtension as a new target.
    // Please refer to IntentHandler (path: ~/QuickStartIntent/IntentHandler.swift)
    // (Optional) To make an outgoing call from url, you need to use `application(_:open:options:)` method. The implementation is very similar as `application(_:continue:restorationHandler:)
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let dialParams = userActivity.dialParams else {
            UIApplication.shared.showError(with: "Could not determine dial params")
            return false
        }
        
        SendBirdCall.authenticateIfNeed { error in
            if let error = error {
                UIApplication.shared.showError(with: error.localizedDescription)
                return
            }
            
            // Make an outgoing call
            SendBirdCall.dial(with: dialParams)
        }
        
        return true
    }
    
    // MARK: - URL Scheme
    // Used URL scheme: sendbird
    // Following method tries to sign in with account information decoded from passed URL.
    // For more information about Custom URL Scheme for your app, see [Defining a Custom URL Scheme for Your App](https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        guard SendBirdCall.currentUser == nil else {
            UIApplication.shared.showError(with: "Please log out current account")
            return false
        }
        
        // Decoding
        SendBirdCredentialManager.shared.decode(url: url) { (credential, error) in
            guard let credential = credential else {
                // Failed
                UIApplication.shared.showError(with: error?.localizedDescription ?? "Failed to sign in with URL")
                
                return
            }
            
            // Succeed
            SendBirdCredentialManager.shared.signIn(with: credential)
        }
        return true
    }
}
