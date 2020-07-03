//
//  UIImage+QuickStart.swift
//  QuickStart
//
//  Created by Damon Park on 2020/03/26.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImage {
    enum QuickStart: String {
        case btnAudioOffSelected
        case btnAudioOff
        
        case btnVideoOffSelected
        case btnVideoOff
        
        case btnBluetoothSelected
        case btnSpeakerSelected
        case btnSpeaker
        
        var image: UIImage? { UIImage.init(named: self.rawValue) }
    }
    
    enum CallDirection {
        case outgoing(_ type: CallType)
        case incoming(_ type: CallType)
        
        enum CallType {
            case voiceCall
            case videoCall
        }
    }
    
    static func audio(isOn: Bool) -> UIImage? {
        (isOn ? QuickStart.btnAudioOffSelected : QuickStart.btnAudioOff).image
    }
    
    static func video(isOn: Bool) -> UIImage? {
        (isOn ? QuickStart.btnVideoOffSelected : QuickStart.btnVideoOff).image
    }
    
    static func audio(output: AVAudioSession.Port) -> UIImage? {
        switch output {
        case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE:
            return QuickStart.btnBluetoothSelected.image
        case .builtInSpeaker:
            return QuickStart.btnSpeakerSelected.image
        default:
            return QuickStart.btnSpeaker.image
        }
    }
    
    /// - Returns: UIImage object based on call type.
    static func callTypeImage(outgoing: Bool, hasVideo: Bool) -> UIImage? {
        let type: CallDirection.CallType = hasVideo ? .videoCall : .voiceCall
        let direction: CallDirection = outgoing ? .outgoing(type) : .incoming(type)
        switch direction {
        case .outgoing(.voiceCall):
            return UIImage(named: "iconCallVoiceOutgoingFilled")
        case .outgoing(.videoCall):
            return UIImage(named: "iconCallVideoOutgoingFilled")
        case .incoming(.voiceCall):
            return UIImage(named: "iconCallVoiceIncomingFilled")
        case .incoming(.videoCall):
            return UIImage(named: "iconCallVideoIncomingFilled")
        }
    }
}
