//
//  AudioOutputsView.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/01/31.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import MediaPlayer

class AudioOutputsView: MPVolumeView {    
    override func routeButtonRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = CGRect(x: 0, y: 0, width: 60, height: 60)
        return newBounds
    }
}
