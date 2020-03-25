//
//  CXCallable.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/25.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import CallKit
import Foundation
import SendBirdCalls

protocol CXCallable {
    func startCXCall(_ call: DirectCall, calleeId: String)
    
    func endCXCall(_ call: DirectCall)
}

extension CXCallable {
    func startCXCall(_ call: DirectCall, calleeId: String) {
        let handle = CXHandle(type: .generic, value: calleeId)
        let startCallAction = CXStartCallAction(call: call.callUUID!, handle: handle)
        startCallAction.isVideo = call.isVideoCall
        
        let transaction = CXTransaction(action: startCallAction)
        
        CXCallControllerManager.requestTransaction(transaction, action: "SendBird - Start Call")
    }
    
    func endCXCall(_ call: DirectCall) {
        let endCallAction = CXEndCallAction(call: call.callUUID!)
        let transaction = CXTransaction(action: endCallAction)
        
        CXCallControllerManager.requestTransaction(transaction, action: "SendBird - End Call")
    }
}
