//
//  SendBirdCall+QuickStart.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/13.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

extension SendBirdCall {
    static func authenticateIfNeed(completionHandler: @escaping (Error?) -> Void) {
        guard SendBirdCall.currentUser == nil else {
            completionHandler(nil)
            return
        }
        
        let params = AuthenticateParams(userId: UserDefaults.standard.user.id, accessToken: UserDefaults.standard.accessToken)
        SendBirdCall.authenticate(with: params) { (user, error) in
            completionHandler(error)
        }
    }
    
    static func dialFromExternal(to calleeId: String, hasVideo: Bool) {
        let callOption = CallOptions(isAudioEnabled: true, isVideoEnabled: hasVideo, localVideoView: nil, remoteVideoView: nil, useFrontCamera: true)
        let dialParams = DialParams(calleeId: calleeId, isVideoCall: hasVideo, callOptions: callOption, customItems: [:])
        SendBirdCall.dial(with: dialParams) { call, error in
            guard let call = call, error == nil else {
                UIApplication.shared.showError(with: error?.localizedDescription ?? "Failed to call with unknown error")
                return
            }
            UIApplication.shared.showCallController(with: call)
        }
    }
}

