//
//  CallText.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import AVFoundation
import SendBirdCalls

/// Text and images that the call screens and the call history show.
enum CallText {
    /// `mm:ss`, or `h:mm:ss` when the call is an hour or longer.
    static func duration(milliseconds: Int64) -> String {
        let totalSeconds = Int(milliseconds / 1000)
        let hours = totalSeconds / 3600
        let minutes = totalSeconds / 60 % 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// For example, `no_answer` becomes `No answer`.
    static func endResult(_ result: DirectCallEndResult) -> String {
        let text = result.rawValue.replacingOccurrences(of: "_", with: " ")
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    /// The image of the audio output button for the current output, such as the speaker or a Bluetooth headset.
    static func audioOutputImageName(for port: AVAudioSession.Port) -> String {
        switch port {
        case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE:
            return "btnBluetoothSelected"
        case .builtInSpeaker:
            return "btnSpeakerSelected"
        default:
            return "btnSpeaker"
        }
    }
}
