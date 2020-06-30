//
//  CXCallController+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import Foundation
import CallKit
import UIKit
import AVFoundation
import SendBirdCalls

class CXCallManager: NSObject {
    static let shared = CXCallManager()
    
    var currentCalls: [CXCall] { self.controller.callObserver.calls }
    
    private let provider: CXProvider
    private let controller = CXCallController()
    
    override init() {
        self.provider = CXProvider.default
        
        super.init()
        
        self.provider.setDelegate(self, queue: .main)
    }
    
    func shouldProcessCall(for callId: UUID) -> Bool {
        return !self.currentCalls.contains(where: { $0.uuid == callId })
    }
}

extension CXCallManager { // Process with CXProvider
    func reportIncomingCall(with callID: UUID, update: CXCallUpdate, completionHandler: ((Error?)->Void)? = nil) {
        self.provider.reportNewIncomingCall(with: callID, update: update) { (error) in
            completionHandler?(error)
        }
    }
    
    func endCall(for callId: UUID, endedAt: Date, reason: DirectCallEndResult) {
        guard let endReason = reason.asCXCallEndedReason else { return }

        self.provider.reportCall(with: callId, endedAt: endedAt, reason: endReason)
    }
    
    func connectedCall(_ call: DirectCall) {
        self.provider.reportOutgoingCall(with: call.callUUID!, connectedAt: Date(timeIntervalSince1970: Double(call.startedAt)/1000))
    }
}

extension CXCallManager { // Process with CXTransaction
    func requestTransaction(_ transaction: CXTransaction, action: String = "") {
        self.controller.request(transaction) { error in
            guard error == nil else {
                print("Error Requesting Transaction: \(String(describing: error))")
                return
            }
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

extension CXCallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) { }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // MARK: SendBirdCalls - SendBirdCall.getCall()
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: (call.isVideoCall ? .videoChat : .voiceChat))
        
        if call.myRole == .caller {
            provider.reportOutgoingCall(with: call.callUUID!, startedConnectingAt: Date(timeIntervalSince1970: Double(call.startedAt)/1000))
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
        SendBirdCall.authenticateIfNeed{ [weak call] (error) in
            guard let call = call, error == nil else {
                action.fail()
                return
            }

            // MARK: SendBirdCalls - DirectCall.accept()
            let callOptions = CallOptions(isAudioEnabled: true, isVideoEnabled: call.isVideoCall, useFrontCamera: true)
            let acceptParams = AcceptParams(callOptions: callOptions)
            call.accept(with: acceptParams)
            
            if var onGoingCallView = UIViewController.topViewController as? DirectCallDataSource {
                onGoingCallView.call.delegate = nil
                onGoingCallView.call = call
                onGoingCallView.reloadData()
            } else {
                UIApplication.shared.showCallController(with: call)
            }
            action.fulfill()
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
        // For decline
        if call.endResult == DirectCallEndResult.none || call.endResult == .unknown {
            SendBirdCall.authenticateIfNeed { [weak call] (error) in
                guard let call = call, error == nil else {
                    action.fail()
                    return
                }
           
                call.end { action.fulfill() }
            }
        } else {
            action.fulfill()
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
        // MARK: SendBirdCalls - DirectCall.muteMicrophone / .unmuteMicrophone()
        action.isMuted ? call.muteMicrophone() : call.unmuteMicrophone()
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) { }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        SendBirdCall.audioSessionDidActivate(audioSession)
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        SendBirdCall.audioSessionDidDeactivate(audioSession)
    }
}

extension DirectCallEndResult {
    var asCXCallEndedReason: CXCallEndedReason? {
        switch self {
        case .connectionLost, .timedOut, .acceptFailed, .dialFailed, .unknown:
            return .failed
        case .completed, .canceled:
            return .remoteEnded
        case .declined:
            return .declinedElsewhere
        case .noAnswer:
            return .unanswered
        case .otherDeviceAccepted:
            return .answeredElsewhere
        case .none: return nil
        @unknown default: return nil
        }
    }
}
