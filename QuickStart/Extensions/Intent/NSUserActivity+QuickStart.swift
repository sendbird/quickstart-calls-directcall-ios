//
//  NSUserActivity+QuickStart.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/08.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation
import Intents
import SendBirdCalls

protocol SupportedStartCallIntent {
    var contacts: [INPerson]? { get }
    var hasVideo: Bool { get }
}

extension INStartAudioCallIntent: SupportedStartCallIntent {
    var hasVideo: Bool { false }
}
extension INStartVideoCallIntent: SupportedStartCallIntent {
    var hasVideo: Bool { true }
}
@available(iOS 13.0, *)
extension INStartCallIntent: SupportedStartCallIntent {
    var hasVideo: Bool { self.callCapability == .videoCall }
}

extension NSUserActivity: StartCallConvertible {
    var dialParams: DialParams? {
        guard let interaction = interaction else { return nil }
        guard let startCallIntent = interaction.intent as? SupportedStartCallIntent else { return nil }
        guard let contact = startCallIntent.contacts?.first else { return nil }  // No callee ID
        guard let calleeId = contact.personHandle?.value else { return nil }
        let hasVideo = startCallIntent.hasVideo
        
        return DialParams(calleeId: calleeId,
                          isVideoCall: hasVideo,
                          callOptions: CallOptions(isAudioEnabled: true,
                                                   isVideoEnabled: hasVideo,
                                                   localVideoView: nil,
                                                   remoteVideoView: nil,
                                                   useFrontCamera: true),
                          customItems: [:])
    }
}
