//
//  IntentHandler.swift
//  QuickStartIntent
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import Intents

/// Starts a call from the Phone app's Recents.
///
/// CallKit adds this app's calls to Recents. When the user taps one, the system sends `INStartCallIntent` here.
/// This extension only checks the intent and opens the app, which makes the call. See `RootView` in the app.
final class IntentHandler: INExtension, INStartCallIntentHandling {
    func handle(intent: INStartCallIntent, completion: @escaping (INStartCallIntentResponse) -> Void) {
        // The other user's ID is the handle of the first contact.
        guard intent.contacts?.first?.personHandle != nil else {
            completion(INStartCallIntentResponse(code: .failure, userActivity: nil))
            return
        }
        let userActivity = NSUserActivity(activityType: String(describing: INStartCallIntent.self))
        completion(INStartCallIntentResponse(code: .continueInApp, userActivity: userActivity))
    }
}
