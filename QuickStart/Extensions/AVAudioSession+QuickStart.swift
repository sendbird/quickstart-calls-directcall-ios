//
//  AVAudioSession+QuickStart.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import AVFoundation

extension AVAudioSession {
    static var `default`: AVAudioSession {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord)
        } catch {}
        return audioSession
    }
    
    func update() {
        do {
            try self.setMode(.voiceChat)
        } catch {}
    }
}
