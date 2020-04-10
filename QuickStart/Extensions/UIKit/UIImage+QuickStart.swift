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
    enum QuickStart : String {
        case btnAudioOffSelected
        case btnAudioOff
        
        case btnVideoOffSelected
        case btnVideoOff
        
        case btnBluetoothSelected
        case btnSpeakerSelected
        case btnSpeaker
        
        var image: UIImage? { UIImage.init(named: self.rawValue) }
    }
    
    static func audio(on: Bool) -> UIImage? {
        (on ? QuickStart.btnAudioOffSelected : QuickStart.btnAudioOff).image
    }
    
    static func video(on: Bool) -> UIImage? {
        (on ? QuickStart.btnVideoOffSelected : QuickStart.btnVideoOff).image
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
}
