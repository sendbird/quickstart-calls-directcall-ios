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
            
            // Make an outgoing call
            let callOption = CallOptions(isAudioEnabled: true, isVideoEnabled: hasVideo, localVideoView: nil, remoteVideoView: nil, useFrontCamera: true)
            let dialParams = DialParams(calleeId: calleeId, isVideoCall: hasVideo, callOptions: callOption, customItems: [:])
            SendBirdCall.dial(with: dialParams)
        }
        
        return true
    }
}
