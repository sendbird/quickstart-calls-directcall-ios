//
//  AppDelegate+SendBirdCallsDelegates.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved..
//

import CallKit
import SendBirdCalls

// MARK: - SendBirdCalls Delegates
extension AppDelegate: SendBirdCallDelegate, DirectCallDelegate {
    // MARK: SendBirdCallDelegate
    func didEnterRinging(_ call: DirectCall) {
        let update = CXCallUpdate()
        
        if let userId = call.caller?.userId {
            update.remoteHandle = CXHandle(type: .generic, value: userId)
        }
        
        guard let callUUID = call.callUUID else { return }
        
        self.provider.reportCall(with: callUUID, updated: update)
    }
    
    // MARK: DirectCallDelegate
    func didConnect(_ call: DirectCall) { }
    
    func didEnd(_ call: DirectCall) {
        var callId: UUID = UUID()
        if let callUUID = call.callUUID {
            callId = callUUID
        }
        
        var reason: CXCallEndedReason = .failed
        switch call.endResult {
        case .completed, .connectionLost, .timedOut, .acceptFailed, .dialFailed, .unknown:
            reason = .failed
        case .canceled:
            reason = .remoteEnded
        case .declined:
            reason = .declinedElsewhere
        case .noAnswer:
            reason = .unanswered
        case .otherDeviceAccepted:
            reason = .answeredElsewhere
        case .none: return
        @unknown default: return
        }
     
        self.provider.reportCall(with: callId, endedAt: Date(), reason: reason)
    }
}
