//
//  AppDelegate+SendBirdCallsDelegates.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved..
//

import UIKit
import CallKit
import SendBirdCalls

// MARK: - Sendbird Calls Delegates
extension AppDelegate: SendBirdCallDelegate, DirectCallDelegate {
    // MARK: SendBirdCallDelegate
    // Handles incoming call. Please refer to `AppDelegate+VoIP.swift` file
    func didStartRinging(_ call: DirectCall) {
        call.delegate = self // To receive call event through `DirectCallDelegate`
        
        guard let uuid = call.callUUID else { return }
        guard CXCallManager.shared.shouldProcessCall(for: uuid) else { return }  // Should be cross-checked with state to prevent weird event processings
        
        // Use CXProvider to report the incoming call to the system
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let name = call.caller?.userId ?? "Unknown"
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: name)
        update.hasVideo = call.isVideoCall
        update.localizedCallerName = call.caller?.userId ?? "Unknown"
        
        if SendBirdCall.getOngoingCallCount() > 1 {
            // Allow only one ongoing call.
            CXCallManager.shared.reportIncomingCall(with: uuid, update: update) { _ in
                CXCallManager.shared.endCall(for: uuid, endedAt: Date(), reason: .declined)
            }
            call.end()
        } else {
            // Report the incoming call to the system
            CXCallManager.shared.reportIncomingCall(with: uuid, update: update)
        }
    }
    
    // MARK: DirectCallDelegate
    func didConnect(_ call: DirectCall) { }
    
    func didEnd(_ call: DirectCall) {
        var callId: UUID = UUID()
        if let callUUID = call.callUUID {
            callId = callUUID
        }
        
        CXCallManager.shared.endCall(for: callId, endedAt: Date(), reason: call.endResult)
        
        guard let callLog = call.callLog else { return }
        UserDefaults.standard.callHistories.insert(CallHistory(callLog: callLog), at: 0)
        
        CallHistoryViewController.main?.updateCallHistories()
    }
}
