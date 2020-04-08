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

class CXCallControllerManager: NSObject {
    static let shared = CXCallControllerManager()
    private let controller = CXCallController()
    
    var currentCalls: [CXCall] { self.controller.callObserver.calls }
    
    private let provider: CXProvider
    
    override init() {
        self.provider = CXProvider.default
        
        super.init()
        
        self.provider.setDelegate(self, queue: .main)
    }
    
    func requestTransaction(_ transaction: CXTransaction, action: String = "") {
        self.controller.request(transaction) { error in
            guard error == nil else { return }
            
            // Requested transaction successfully
        }
    }
    
    func reportIncomingCall(with callID: UUID, update: CXCallUpdate, completionHandler: ((Error?)->Void)? = nil) {
        self.provider.reportNewIncomingCall(with: callID, update: update) { (error) in
            completionHandler?(error)
        }
    }
    
    func endCall(for callId: UUID, endedAt: Date, reason: CXCallEndedReason) {
        self.provider.reportCall(with: callId, endedAt: endedAt, reason: reason)
    }
    
    func connectedCall(_ call: DirectCall) {
        self.provider.reportOutgoingCall(with: call.callUUID!, connectedAt: Date(timeIntervalSince1970: Double(call.startedAt)/1000))
    }
}

extension CXCallControllerManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        //
    }
    
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
        
        // MARK: SendBirdCalls - DirectCall.accept()
        let callOptions = CallOptions(isAudioEnabled: true, isVideoEnabled: call.isVideoCall, useFrontCamera: true)
        let acceptParams = AcceptParams(callOptions: callOptions)
        call.accept(with: acceptParams)
        
        // If there is termination: Failed to load VoiceCallViewController from Main.storyboard. Please check its storyboard ID")
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: call.isVideoCall ? "VideoCallViewController" : "VoiceCallViewController")

        if var dataSource = viewController as? DirectCallDataSource {
            dataSource.call = call
            dataSource.isDialing = false
        }
        
        if let topViewController = UIViewController.topViewController {
            topViewController.present(viewController, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        }
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }
    
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
        // For decline
        let params = AuthenticateParams(userId: UserDefaults.standard.user.id, accessToken: UserDefaults.standard.accessToken)
        SendBirdCall.authenticate(with: params) { (user, error) in
            call.end {
                action.fulfill()
            }
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
}
