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
        guard SendBirdCall.getCall(forUUID: action.callUUID) != nil else { return }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        AVAudioSession.default.update()
        
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
        // MARK: SendBirdCalls - DirectCall.accept()
        call.accept(callOptions: CallOptions(isAudioEnabled: true))
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CallingViewController")
        guard let callingVC = viewController as? CallingViewController else { return } // If there is termination: Failed to load CallingViewController from Main.storyboard. Please check its storyboard ID")
                                        
        callingVC.call = call
        callingVC.isDialing = false
        
        if let topViewController = UIViewController.topViewController {
            topViewController.present(callingVC, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController = callingVC
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
