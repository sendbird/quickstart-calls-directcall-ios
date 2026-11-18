//
//  AppDelegate+URLScheme.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/09/18.
//  Copyright © 2020 Sendbird Inc. All rights reserved.
//

import UIKit

// MARK: - URL Scheme
// Used URL scheme: sendbird
// Following method tries to sign in with account information decoded from passed URL.
// For more information about Custom URL Scheme for your app, see [Defining a Custom URL Scheme for Your App](https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)

extension AppDelegate {    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        // Authenticate only when there is no signed in account
        guard UserDefaults.standard.credential == nil else {
            UIApplication.shared.showError(with: CredentialErrors.alreadyAuthenticated.localizedDescription)
            return false
        }
        
        // Get credential from the URL and authenticate
        do {
            let pendingCredential = try CredentialManager.shared.handle(url: url)
            self.authenticate(with: pendingCredential) { error in
                if let error = error {
                    // Failed to authenticate
                    UIApplication.shared.showError(with: error.localizedDescription)
                    return
                }
                
                guard let signInVC = self.window?.rootViewController?.presentedViewController else { return }
                signInVC.dismiss(animated: true, completion: nil)
            }
        } catch {
            // Failed to decode URL
            UIApplication.shared.showError(with: error.localizedDescription)
            return false
        }
        
        return true
    }
}
