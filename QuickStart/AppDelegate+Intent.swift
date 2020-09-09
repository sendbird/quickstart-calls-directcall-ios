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
}
