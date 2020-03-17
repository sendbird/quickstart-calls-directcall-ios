//
//  VideoCallViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/11.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import CallKit
import AVFoundation
import SendBirdCalls

class VideoCallViewController: UIViewController {
    // Video Views
    @IBOutlet weak var localVideoView: UIView?
    
    // Labels
    @IBOutlet weak var callStatusLabel: UILabel!
    @IBOutlet weak var mutedStateLabel: UILabel!
    @IBOutlet weak var remoteUserIdLabel: UILabel!
    
    // ImageView
    @IBOutlet weak var mutedStateImageView: UIImageView!
    @IBOutlet weak var remoteProfileImageView: UIImageView!
    
    // Buttons
    @IBOutlet weak var audioRouteButton: UIButton!
    @IBOutlet weak var audioOffButton: UIButton!
    @IBOutlet weak var videoOffButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    
    // Contstraints of local video view
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstratin: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var call: DirectCall!
    var isDialing: Bool?
    
    let callController = CXCallController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.call.delegate = self
        
        if isDialing ?? false {
            guard let calleeId = self.call.remoteUser?.userId else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            self.dialed(to: calleeId)
        }
        self.setupVideoView()
        self.setupUI(in: self)
        self.updateRemoteAudio(isEnabled: true, call: self.call, in: self)
        self.setupAudioOutputButton()
    }
    
    // MARK: - Video
    func setupVideoView() {
        let localSBVideoView = SendBirdVideoView(frame: localVideoView?.frame ?? CGRect.zero)
        let remoteSBVideoView = SendBirdVideoView(frame: view?.frame ?? CGRect.zero)
        
        self.call.updateLocalVideoView(localSBVideoView)
        self.call.updateRemoteVideoView(remoteSBVideoView)
        
        self.localVideoView?.embed(localSBVideoView)
        self.view?.embed(remoteSBVideoView)
    }
    
    // MARK: - IBActions
    @IBAction func didTapFilpCamera() {
        self.alertError(message: "Camera selection is not supported in Calls \(SendBirdCall.sdkVersion)")
    }
    
    @IBAction func didTapAudioOnOff(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.updateLocalAudio(isEnabled: sender.isSelected)
    }
    
    @IBAction func didTapVideoOnOff(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.updateLocalVideo(isEnabled: sender.isSelected)
    }
    
    @IBAction func didTapEnd() {
        self.endButton.isEnabled = false
        
        guard let call = SendBirdCall.getCall(forCallId: self.call.callId) else { return }
        
        call.end()
        
        self.requestEndTransaction(of: call)
    }
    
    // MARK: - Call Methods
    func dialed(to calleeId: String) {
        
        let handle = CXHandle(type: .generic, value: calleeId)
        
        let startCallAction = CXStartCallAction(call: call.callUUID!, handle: handle)
        startCallAction.isVideo = call.isVideoCall
        
        let transaction = CXTransaction(action: startCallAction)
        
        CXCallControllerManager.requestTransaction(transaction, action: "SendBird - Start Call")
    }
    
    func requestEndTransaction(of call: DirectCall) {
        let endCallAction = CXEndCallAction(call: call.callUUID!)
        let transaction = CXTransaction(action: endCallAction)
        
        CXCallControllerManager.requestTransaction(transaction, action: "SendBird - End Call")
    }
}

// MARK: - Audio I/O
extension VideoCallViewController {
    func setupAudioOutputButton() {
        let width = self.audioRouteButton.frame.width
        let height = self.audioRouteButton.frame.height
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        
        let routePickerView = SendBirdCall.routePickerView(frame: frame)
        self.customize(routePickerView)
        self.audioRouteButton.addSubview(routePickerView)
    }
    
    func customize(_ routePickerView: UIView) {
        if #available(iOS 11.0, *) {
            guard let routePickerView = routePickerView as? AVRoutePickerView else { return }
            routePickerView.activeTintColor = .clear
            routePickerView.tintColor = .clear
        } else {
            guard let volumeView = routePickerView as? MPVolumeView else { return }
            
            volumeView.showsVolumeSlider = false
            volumeView.setRouteButtonImage(nil, for: .normal)
            volumeView.routeButtonRect(forBounds: volumeView.frame)
        }
    }
}

// MARK: - SendBirdCall - DirectCallDelegate
extension VideoCallViewController: DirectCallDelegate {
    // MARK: Required Methods
    func didConnect(_ call: DirectCall) {
        self.remoteUserIdLabel.isHidden = true
        self.callStatusLabel.isHidden = true
        self.updateRemoteAudio(isEnabled: call.isRemoteAudioEnabled, call: call, in: self)
    }
    
    func didEnd(_ call: DirectCall) {
        self.setupEndedCallUI(in: self)
        
        guard let enderId = call.endedBy?.userId, let myId = SendBirdCall.currentUser?.userId, enderId != myId else { return }
        guard let call = SendBirdCall.getCall(forCallId: self.call.callId) else { return }
        self.requestEndTransaction(of: call)
    }
    
    // MARK: Optional Methods
    func didEstablish(_ call: DirectCall) {
        self.setupEstabilshedCallUI(in: self)
        self.resizeLocalVideoView(in: self)
    }
    
    func didRemoteAudioSettingsChange(_ call: DirectCall) {
        self.updateRemoteAudio(isEnabled: call.isRemoteAudioEnabled, call: call, in: self)
    }
    
    func didRemoteVideoSettingsChange(_ call: DirectCall) {
        self.updateRemoteVideo(isEnabled: call.isRemoteVideoEnabled, in: self)
    }
    
    func didAudioDeviceChange(_ call: DirectCall, session: AVAudioSession, previousRoute: AVAudioSessionRouteDescription, reason: AVAudioSession.RouteChangeReason) {
        guard !call.isEnded else { return }
        guard let output = session.currentRoute.outputs.first else { return }
        
        let outputType = output.portType
        let outputName = output.portName
        
        // Customize images
        var imageName = "btnSpeaker"
        switch outputType {
        case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE: imageName = "btnBluetoothSelected"
        case .builtInSpeaker: imageName = "btnSpeakerSelected"
        default: imageName = "btnSpeaker"
        }
        
        self.audioRouteButton.setBackgroundImage(UIImage(named: imageName), for: .normal)
        print("[QuickStart] Audio Route has been changed to \(outputName)")
    }
}

extension VideoCallViewController: CallViewable {
    // MARK: Audio
    func updateLocalAudio(isEnabled: Bool) {
        self.audioOffButton.setBackgroundImage(UIImage(named: isEnabled ? "btnAudioOffSelected" : "btnAudioOff"), for: .normal)
        if isEnabled {
            call?.muteMicrophone()
        } else {
            call?.unmuteMicrophone()
        }
    }
    
    // MARK: Video
    func updateLocalVideo(isEnabled: Bool) {
        self.videoOffButton.setBackgroundImage(UIImage(named: isEnabled ? "btnVideoOffSelected" : "btnVideoOff"), for: .normal)
        if isEnabled {
            call.stopVideo()
        } else {
            call.startVideo()
        }
    }
}
