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
    
    // MARK: - From URL
    // To make an outgoing call from url, you need to implement this method
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let calleeId = url.calleeId else { return false }
        
        SendBirdCall.authenticateIfNeed { error in
            guard error == nil else {
                UIApplication.shared.showError(with: error?.localizedDescription ?? "Failed to call with unknown error")
                return
            }
            SendBirdCall.dialFromExternal(to: calleeId, hasVideo: false)
        }
        return true
    }
    
    // MARK: - From Native Call Logs
    // To make an outgoing call from native call logs, so called "Recents" in iPhone, you need to implement this method and add IntentExtension as a new target.
    // Please refer to IntentHandler (path: ~/QuickStartIntent/IntentHandler.swift)
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let calleeId = userActivity.calleeId else {
            UIApplication.shared.showError(with: "Could not determine callee ID")
            return false
        }
        
        guard let hasVideo = userActivity.hasVideo else {
            UIApplication.shared.showError(with: "Could not determine video from call log")
            return false
        }
        
        SendBirdCall.authenticateIfNeed { error in
            guard error == nil else {
                UIApplication.shared.showError(with: error?.localizedDescription ?? "Failed to call with unknown error")
                return
            }
            SendBirdCall.dialFromExternal(to: calleeId, hasVideo: hasVideo)
        }
        
        return true
    }
}
