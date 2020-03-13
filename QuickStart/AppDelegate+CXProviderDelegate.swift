//
//  AppDelegate+CXProviderDelegate.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation
import SendBirdCalls

extension AppDelegate: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        //
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // MARK: SendBirdCalls - SendBirdCall.getCall()
        guard SendBirdCall.getCall(forUUID: action.callUUID) != nil else {
            action.fail()
            return
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
        // MARK: SendBirdCalls - DirectCall.accept()
        let callOptions = CallOptions(isAudioEnabled: true, isVideoEnabled: call.isVideoCall)
        let acceptParams = AcceptParams(callOptions: callOptions)
        call.accept(with: acceptParams)
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: call.isVideoCall ? "VideoCallViewController" : "VoiceCallViewController")

        // If there is termination: Failed to load VoiceCallViewController from Main.storyboard. Please check its storyboard ID")
        if call.isVideoCall, let videeCallVC = viewController as? VideoCallViewController {
            videeCallVC.call = call
            videeCallVC.isDialing = false
            
            if let topViewController = UIViewController.topViewController {
                topViewController.present(videeCallVC, animated: true, completion: nil)
            } else {
                UIApplication.shared.keyWindow?.rootViewController = videeCallVC
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
            }
        }
        if !call.isVideoCall, let voiceCallVC = viewController as? VoiceCallViewController {
            voiceCallVC.call = call
            voiceCallVC.isDialing = false
            
            if let topViewController = UIViewController.topViewController {
                topViewController.present(voiceCallVC, animated: true, completion: nil)
            } else {
                UIApplication.shared.keyWindow?.rootViewController = voiceCallVC
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
            }
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
        if call.endResult == .unknown {
            call.end()
        }
        
        action.fulfill()
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
}
