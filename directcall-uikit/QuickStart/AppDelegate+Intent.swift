//
//  AppDelegate+Intent.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/08.
//  Copyright © 2020 Sendbird Inc. All rights reserved.
//

import UIKit
import CallKit
import SendBirdCalls

// MARK: - From Native Call Logs
// To make an outgoing call from native call logs, so called "Recents" in iPhone, you need to implement this method and add IntentExtension as a new target.
// Please refer to IntentHandler (path: ~/QuickStartIntent/IntentHandler.swift)
// `SceneDelegate` calls the method below with the user activity of the call, because the app uses the scene life cycle.
// (Optional) To make an outgoing call from url, handle the URL in `SceneDelegate` in a similar way.

extension AppDelegate {
    
    @discardableResult
    func handle(userActivity: NSUserActivity) -> Bool {
        guard let dialParams = userActivity.dialParams else {
            UIApplication.shared.showError(with: DialErrors.getLogFailed.localizedDescription)

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
