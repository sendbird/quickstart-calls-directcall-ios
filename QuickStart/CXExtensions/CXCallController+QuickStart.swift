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
    
    static func requestTransaction(_ transaction: CXTransaction, action: String = "") {
        self.sharedController.request(transaction) { error in
            guard error == nil else { return }
            
            // Requested transaction successfully
        }
    }
}
