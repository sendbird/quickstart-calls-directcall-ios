//
//  CXCallController+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import Foundation
import CallKit
import SendBirdCalls

extension CXCallController {
    static let shared = CXCallController()
    
    private func requestTransaction(_ transaction: CXTransaction) {
        CXCallController.shared.request(transaction) { error in
            guard error == nil else { return }
            
            // Requested transaction successfully
        }
    }
    
    func startCXCall(_ call: DirectCall, completionHandler: @escaping ((Bool) -> Void)) {
        guard let calleeId = call.callee?.userId else {
            DispatchQueue.main.async {
                completionHandler(false)
            }
            return
        }
        let handle = CXHandle(type: .generic, value: calleeId)
        let startCallAction = CXStartCallAction(call: call.callUUID!, handle: handle)
        startCallAction.isVideo = call.isVideoCall
        
        let transaction = CXTransaction(action: startCallAction)
        
        self.requestTransaction(transaction)
        
        DispatchQueue.main.async {
            completionHandler(true)
        }
    }
    
    func endCXCall(_ call: DirectCall) {
        let endCallAction = CXEndCallAction(call: call.callUUID!)
        let transaction = CXTransaction(action: endCallAction)
        
        self.requestTransaction(transaction)
    }
}
