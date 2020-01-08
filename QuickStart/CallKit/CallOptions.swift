//
//  CallOptions.swift
//  V2oIP
//
//  Created by Jaesung Lee on 2019/11/04.
//  Copyright © 2019 SendBird. All rights reserved.
//
import UIKit


public class CallOptions {
    // MARK: UI Information
//    weak var localVideoView: RTCCameraPreviewView!
//    weak var remoteVideoView: RTCMTLVideoView!
    
    // 기존 비디오챗에 맞춰서 타입 정하기
    var videoWidth: CGFloat?
    var videoHeight: CGFloat?
    var videoFPS: Int?
    
    // MARK: Call Information
    /**
    If `true`, the call is for audio only.
    
    - caller: dial
    
    - callee: receive dial
    */
    var isAudioCall: Bool
    
    var constraints: CallConstraints
    
    var isCameraFront: Bool
    
    
    
    init(isAudioCall: Bool = true, constraints: CallConstraints = CallConstraints(), width: CGFloat? = nil, height: CGFloat? = nil, fps: Int? = nil) {
        self.isCameraFront = true
        self.isAudioCall = isAudioCall
        self.constraints = constraints
        self.videoWidth = width
        self.videoHeight = height
        self.videoFPS = fps
    }
}
