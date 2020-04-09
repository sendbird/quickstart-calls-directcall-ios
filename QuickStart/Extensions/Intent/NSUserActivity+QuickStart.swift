//
//  NSUserActivity+QuickStart.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/08.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation
import Intents

protocol SupportedStartCallIntent {
    var contacts: [INPerson]? { get }
}

extension INStartAudioCallIntent: SupportedStartCallIntent { }
extension INStartVideoCallIntent: SupportedStartCallIntent { }
@available(iOS 13.0, *)
extension INStartCallIntent: SupportedStartCallIntent { }


extension NSUserActivity: StartCallConvertible {
    var calleeId: String? {
        guard
          let interaction = interaction,
          let startCallIntent = interaction.intent as? SupportedStartCallIntent,
          let contact = startCallIntent.contacts?.first
        else { return nil }

        return contact.personHandle?.value
    }

    var hasVideo: Bool? {
        guard
          let interaction = interaction,
          let startCallIntent = interaction.intent as? SupportedStartCallIntent
        else { return nil }

        if #available(iOS 13.0, *) {
            return startCallIntent is INStartCallIntent
        } else {
            // Fallback on earlier versions
            return startCallIntent is INStartVideoCallIntent
        }
    }
    
}
