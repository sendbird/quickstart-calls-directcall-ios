//
//  CXCallController+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import Foundation
import CallKit
import SendBirdCalls

protocol CXCallRequestable { }

extension CXCallRequestable {
    private func requestTransaction(_ transaction: CXTransaction, action: String = "") {
        CXCallController.shared.request(transaction) { error in
            guard error == nil else { return }
            
            // Requested transaction successfully
        }
    }
    
    func startCXCall(_ call: DirectCall) {
        guard let calleeId = call.callee?.userId else {
            CXCallController.isRequested = false
            return
        }
        CXCallController.isRequested = true
        
        let handle = CXHandle(type: .generic, value: calleeId)
        let startCallAction = CXStartCallAction(call: call.callUUID!, handle: handle)
        startCallAction.isVideo = call.isVideoCall
        
        let transaction = CXTransaction(action: startCallAction)
        
        self.requestTransaction(transaction, action: "SendBird - Start Call")
    }
    
    func endCXCall(_ call: DirectCall) {
        let endCallAction = CXEndCallAction(call: call.callUUID!)
        let transaction = CXTransaction(action: endCallAction)
        
        self.requestTransaction(transaction, action: "SendBird - End Call")
    }
}

extension CXCallController: CXCallRequestable {
    static let shared = CXCallController()
    
    static var isRequested = false  // `true` when the callee ID is valid, so it available to request transaction.
}
