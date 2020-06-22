//
//  IntentHandler.swift
//  QuickStartIntent
//
//  Created by Jaesung Lee on 2020/04/08.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Intents

// To make an outgoing call from native call logs, so called "Recents" in iPhone, IntentExtension is required.
class IntentHandler: INExtension, INStartVideoCallIntentHandling, INStartAudioCallIntentHandling {
    func handle(intent: INStartVideoCallIntent, completion: @escaping (INStartVideoCallIntentResponse) -> Void) {
        let response: INStartVideoCallIntentResponse
        defer { completion(response) }
        
        // Ensure there is a person handle
        guard intent.isValid else {
            response = INStartVideoCallIntentResponse(code: .failure, userActivity: nil)
            return
        }
        
        let userActivity = NSUserActivity(activityType: String(describing: INStartVideoCallIntent.self))
        
        response = INStartVideoCallIntentResponse(code: .continueInApp, userActivity: userActivity)
    }
    
    func handle(intent: INStartAudioCallIntent, completion: @escaping (INStartAudioCallIntentResponse) -> Void) {
        let response: INStartAudioCallIntentResponse
        defer { completion(response) }

        // Ensure there is a person handle
        guard intent.isValid else {
            response = INStartAudioCallIntentResponse(code: .failure, userActivity: nil)
            return
        }

        let userActivity = NSUserActivity(activityType: String(describing: INStartAudioCallIntent.self))

        response = INStartAudioCallIntentResponse(code: .continueInApp, userActivity: userActivity)
    }
}

@available(iOS 13.0, *)
extension IntentHandler: INStartCallIntentHandling {
    // If your app targets to iOS 13.0, you can remove above method and `INStartAudioCallIntentHandling` protocol
    func handle(intent: INStartCallIntent, completion: @escaping (INStartCallIntentResponse) -> Void) {
        let response: INStartCallIntentResponse
        defer { completion(response) }

        // Ensure there is a person handle
        guard intent.isValid else {
            response = INStartCallIntentResponse(code: .failure, userActivity: nil)
            return
        }

        let userActivity = NSUserActivity(activityType: String(describing: INStartCallIntent.self))

        response = INStartCallIntentResponse(code: .continueInApp, userActivity: userActivity)
    }
}

