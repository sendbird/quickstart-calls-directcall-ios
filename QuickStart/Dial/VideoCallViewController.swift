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
        self.callStatusLabel.text = "Calling..."
        
        // Remote Info
        let profileURL = self.call.remoteUser?.profileURL
        self.remoteProfileImageView.setImage(urlString: profileURL)
        self.remoteUserIdLabel.text = self.call.remoteUser?.userId
        self.updateRemoteAudio(isOn: self.call.isRemoteAudioEnabled)
        
        // Local Info
        self.muteAudioButton.isSelected = !self.call.isLocalAudioEnabled
        
        // AudioOutputs
        self.setupAudioOutputButton()
    }
    
    // MARK: Video
    func setupVideoView() {
        
        let localSBVideoView = SendBirdVideoView(frame: localVideoView?.frame ?? CGRect.zero)
//        let remoteSBVideoView = SendBirdVideoView(frame: view?.frame ?? CGRect.zero)
        
        self.call.updateLocalVideoView(localSBVideoView)
//        self.call.updateRemoteVideoView(remoteSBVideoView)
        
        self.localVideoView?.embed(localSBVideoView)
//        self.view?.embed(remoteSBVideoView)
        
    }
    
    // MARK: - IBActions
    @IBAction func didTapFilpCamera() {
        self.alertError(message: "Camera selection is not supported in 0.8.0")
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

// MARK: - SendBirdCall - DirectCall audio mute / unmute
extension VideoCallViewController {
    func updateLocalAudio(isEnabled: Bool) {
        if isEnabled {
            call?.muteMicrophone()
        } else {
            call?.unmuteMicrophone()
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
        } else {
            call.startVideo()
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
            self?.remoteProfileImageView.isHidden = false
            self?.callStatusLabel.text = "Ended"
            self?.endButton.isEnabled = true
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
