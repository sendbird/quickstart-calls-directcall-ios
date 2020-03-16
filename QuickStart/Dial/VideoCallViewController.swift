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
    
    var call: DirectCall!
    var isDialing: Bool?
    
    let callController = CXCallController()

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
        self.callStatusLabel.text = "Calling..."
        
        // Remote Info
        let profileURL = self.call.remoteUser?.profileURL
        self.remoteProfileImageView.setImage(urlString: profileURL)
        self.remoteProfileImageView.alpha = 0.7
        
        self.remoteUserIdLabel.text = self.call.remoteUser?.userId
        self.updateRemoteAudio(isOn: true)
        
        // Local Info
        self.audioOffButton.isSelected = !self.call.isLocalAudioEnabled
        
        // AudioOutputs
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
    
    @IBAction func didTapAudioOnOff(_ sender: UIButton?) {
        guard let sender = sender else { return }
        sender.isSelected.toggle()
        self.updateLocalAudio(isEnabled: sender.isSelected)
    }
    
    @IBAction func didTapVideoOnOff(_ sender: UIButton?) {
        guard let sender = sender else { return }
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

// MARK: - SendBirdCall - DirectCall audio mute / unmute
extension VideoCallViewController {
    func updateLocalAudio(isEnabled: Bool) {
        if isEnabled {
            call?.muteMicrophone()
            self.audioOffButton.setBackgroundImage(UIImage(named: "btnAudioOff"), for: .normal)
        } else {
            call?.unmuteMicrophone()
            self.audioOffButton.setBackgroundImage(UIImage(named: "btnAudioOffSelected"), for: .normal)
        }
    }
    
    func updateRemoteAudio(isOn: Bool) {
        DispatchQueue.main.async { [weak self] in
            if isOn {
                self?.mutedStateImageView.isHidden = true
                self?.mutedStateLabel.isHidden = true
            } else {
                self?.mutedStateImageView.isHidden = false
                if let calleeId = self?.call.callee?.userId {
                    self?.mutedStateLabel.text = "\(calleeId) muted this call"
                    self?.mutedStateLabel.isHidden = false
                }
                
            }
        }
    }
}

// MARK: - SendBirdCall - DirectCall video start / stop
extension VideoCallViewController {
    func updateLocalVideo(isEnabled: Bool) {
        if isEnabled {
            call.stopVideo()
            self.videoOffButton.setBackgroundImage(UIImage(named: "btnVideoOffSelected"), for: .normal)
            
        } else {
            call.startVideo()
            self.videoOffButton.setBackgroundImage(UIImage(named: "btnVideoOff"), for: .normal)
        }
    }
}


// MARK: - SendBirdCall - DirectCallDelegate
extension VideoCallViewController: DirectCallDelegate {
    // MARK: Required Methods
    func didConnect(_ call: DirectCall) {
        DispatchQueue.main.async { [weak self] in
            self?.remoteUserIdLabel.isHidden = true
            self?.callStatusLabel.isHidden = true
            self?.updateRemoteAudio(isOn: call.isRemoteAudioEnabled)
        }
    }
    
    func didEnd(_ call: DirectCall) {
        DispatchQueue.main.async { [weak self] in
            // Tell user that the call has been ended.
            self?.callStatusLabel.text = "Ended"
            self?.callStatusLabel.isHidden = false
            self?.remoteUserIdLabel.isHidden = false
            self?.endButton.isEnabled = true
            
            // Release resource
            self?.view.subviews[0].removeFromSuperview()
            self?.localVideoView?.isHidden = true
            self?.remoteProfileImageView.isHidden = false
            self?.mutedStateImageView.isHidden = true
            self?.mutedStateLabel.isHidden = true
            
            // Go back to `Dial` view
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
        guard let enderId = call.endedBy?.userId, let myId = SendBirdCall.currentUser?.userId, enderId != myId else { return }
        guard let call = SendBirdCall.getCall(forCallId: self.call.callId) else { return }
        self.requestEndTransaction(of: call)
        
    }
    
    // MARK: Optional Methods
    func didEstablish(_ call: DirectCall) {
        DispatchQueue.main.async { [weak self] in
            self?.callStatusLabel.text = "Connecting..."
            self?.remoteProfileImageView.isHidden = true
        }
    }
    
    func didRemoteAudioSettingsChange(_ call: DirectCall) {
        DispatchQueue.main.async { [weak self] in
            self?.updateRemoteAudio(isOn: call.isRemoteAudioEnabled)
        }
    }
    
    func didRemoteVideoSettingsChange(_ call: DirectCall) {
        DispatchQueue.main.async { [weak self] in
            self?.remoteProfileImageView.isHidden = call.isRemoteVideoEnabled
        }
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
        
        DispatchQueue.main.async { [weak self] in
            self?.audioRouteButton.setBackgroundImage(UIImage(named: imageName), for: .normal)
            print("[QuickStart] Audio Route has been changed to \(outputName)")
        }
    }
}
