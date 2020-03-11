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
    @IBOutlet weak var remoteVideoView: UIView?
    
    // Buttons
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var muteAudioButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    
    var call: DirectCall!
    var isDialing: Bool?
    
    let callController = CXCallController()
    // MARK: - SendBirdCall - DirectCallDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.call.delegate = self
        
        self.modalPresentationStyle = .formSheet
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
        if isDialing ?? false {
            guard let calleeId = self.call.remoteUser?.userId else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            self.dialed(to: calleeId)
        }
        self.setupUI()
        self.setupVideoView()
    }
    
    func setupUI() {
        // Remote Info
        self.updateRemoteAudio(isOn: self.call.isRemoteAudioEnabled)
        
        // Local Info
        let audioButtonImage: UIImage? = call.isLocalAudioEnabled ? .unmutedAudioImage : .mutedAudioImage
        self.muteAudioButton.isSelected = !self.call.isLocalAudioEnabled
        self.muteAudioButton.setImage(audioButtonImage, for: .normal)
        self.muteAudioButton.rounding()
        
        self.endButton.rounding()
        
        // AudioOutputs
        self.setAudioOutputsView()
    }
    
    func setupVideoView() {
        let localSBVideoView = SendBirdVideoView(frame: self.localVideoView?.frame ?? CGRect.zero)
        let remoteSBVideoView = SendBirdVideoView(frame: self.remoteVideoView?.frame ?? CGRect.zero)
        
        call.updateLocalVideoView(localSBVideoView)
        call.updateRemoteVideoView(remoteSBVideoView)
        
        DispatchQueue.main.async {
            self.localVideoView?.embed(localSBVideoView)
            self.remoteVideoView?.embed(remoteSBVideoView)
        }
    }
    
    // MARK: - IBActions
    
    
    @IBAction func didTapAudioOption(_ sender: UIButton?) {
        guard let sender = sender else { return }
        sender.isSelected.toggle()
        self.updateLocalAudio(enabled: sender.isSelected)
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
    func setAudioOutputsView() {
        self.speakerButton.rounding()
        self.speakerButton.layer.borderColor = UIColor.purple.cgColor
        self.speakerButton.layer.borderWidth = 2.0
        
        let width = self.speakerButton.frame.width
        let height = self.speakerButton.frame.height
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        
        let routePickerView = SendBirdCall.routePickerView(frame: frame)
        self.customize(routePickerView)
        self.speakerButton.addSubview(routePickerView)
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

// MARK: - SendBirdCall - DirectCall duration & mute / unmute
extension VideoCallViewController {
    func updateLocalAudio(enabled: Bool) {
        if enabled {
            self.muteAudioButton.setImage(UIImage.mutedAudioImage, for: .normal)
            call?.muteMicrophone()
        } else {
            self.muteAudioButton.setImage(UIImage.unmutedAudioImage, for: .normal)
            call?.unmuteMicrophone()
        }
    }
    
    func updateRemoteAudio(isOn: Bool) { }
}


// MARK: - SendBirdCall - DirectCallDelegate
extension VideoCallViewController: DirectCallDelegate {
    // This method is required
    func didConnect(_ call: DirectCall) {
        DispatchQueue.main.async {
            self.updateRemoteAudio(isOn: self.call.isRemoteAudioEnabled)
        }
    }
    
    // This method is optional
    func didRemoteAudioSettingsChange(_ call: DirectCall) {
        DispatchQueue.main.async {
            self.updateRemoteAudio(isOn: call.isRemoteAudioEnabled)
        }
    }
    
    // This method is required
    func didEnd(_ call: DirectCall) {
        DispatchQueue.main.async {
            self.endButton.isEnabled = true
            self.dismiss(animated: true, completion: nil)
        }
        
        guard let enderId = call.endedBy?.userId, let myId = SendBirdCall.currentUser?.userId, enderId != myId else { return }
        guard let call = SendBirdCall.getCall(forCallId: self.call.callId) else { return }
        self.requestEndTransaction(of: call)
        
    }
    
    func didAudioDeviceChange(_ call: DirectCall, session: AVAudioSession, previousRoute: AVAudioSessionRouteDescription, reason: AVAudioSession.RouteChangeReason) {
        guard let output = session.currentRoute.outputs.first else { return }
        
        let outputType = output.portType
        let outputName = output.portName
        
        // Customize images
        var imageURL = "mic"
        switch outputType {
        case .airPlay: imageURL = "airplayvideo"
        case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE: imageURL = "headphones"
        case .builtInReceiver: imageURL = "phone.fill"
        case .builtInSpeaker: imageURL = "mic"
        case .headphones: imageURL = "headphones"
        case .headsetMic: imageURL = "headphones"
        default: imageURL = "mic"
        }
        
        DispatchQueue.main.async {
            if #available(iOS 13.0, *) {
                self.speakerButton.setBackgroundImage(nil, for: .normal)
                self.speakerButton.setImage(UIImage(systemName: imageURL), for: .normal)
            } else {
                self.speakerButton.setBackgroundImage(UIImage(named: "icChatAudioPurple"), for: .normal)
            }
            
            let alert = UIAlertController(title: nil, message: "Changed to \(outputName)", preferredStyle: .actionSheet)
            self.present(alert, animated: true, completion: nil)
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
                alert.dismiss(animated: true, completion: nil)
                timer.invalidate()
            }
        }
    }
}
