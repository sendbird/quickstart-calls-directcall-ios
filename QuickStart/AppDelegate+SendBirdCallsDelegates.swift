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
    func didStartRinging(_ call: DirectCall) {
        guard let uuid = call.callUUID else { return }
        guard CXCallController.shared.callObserver.calls.isEmpty else { return }  // Should be cross-checked with state to prevent weird event processings
        
        // Use CXProvider to report the incoming call to the system
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let name = call.caller?.userId ?? "Unknown"
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: name)
        update.hasVideo = call.isVideoCall
        
        // Report the incoming call to the system
        self.provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if error == nil {
                // success
            }
        }
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
