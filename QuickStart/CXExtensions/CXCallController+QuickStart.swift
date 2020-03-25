//
//  CXCallController+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import Foundation
import CallKit
import SendBirdCalls

class CXCallControllerManager {
    static let sharedController = CXCallController()
    
    private static func requestTransaction(_ transaction: CXTransaction, action: String = "") {
        self.sharedController.request(transaction) { error in
            guard error == nil else { return }
            
            // Requested transaction successfully
        }
    }
    
    static func startCXCall(_ call: DirectCall, calleeId: String) {
        let handle = CXHandle(type: .generic, value: calleeId)
        let startCallAction = CXStartCallAction(call: call.callUUID!, handle: handle)
        startCallAction.isVideo = call.isVideoCall
        
        let transaction = CXTransaction(action: startCallAction)
        
        self.requestTransaction(transaction, action: "SendBird - Start Call")
    }
    
    static func endCXCall(_ call: DirectCall) {
        let endCallAction = CXEndCallAction(call: call.callUUID!)
        let transaction = CXTransaction(action: endCallAction)
        
        self.requestTransaction(transaction, action: "SendBird - End Call")
    }
}
