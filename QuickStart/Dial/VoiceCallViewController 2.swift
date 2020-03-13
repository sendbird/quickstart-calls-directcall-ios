//
//  VoiceCallViewController.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import AVKit
import CallKit
import MediaPlayer
import SendBirdCalls

class VoiceCallViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var muteAudioButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var callTimerLabel: UILabel!
    
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
    }
    
    func setupUI() {
        // Remote Info
        self.callTimerLabel.text = "Waiting for connection..."
        
        let profileURL = self.call.remoteUser?.profileURL
        self.profileImageView.setImage(urlString: profileURL)
        
        self.nameLabel.text = self.call.remoteUser?.userId
        self.updateRemoteAudio(isOn: self.call.isRemoteAudioEnabled)
        
        // Local Info
        let audioButtonImage: UIImage? = call.isLocalAudioEnabled ? .unmutedAudioImage : .mutedAudioImage
        self.muteAudioButton.isSelected = !self.call.isLocalAudioEnabled
        self.muteAudioButton.setImage(audioButtonImage, for: .normal)
        
        // AudioOutputs
        self.setupAudioOutputButton()
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
extension VoiceCallViewController {
    func setupAudioOutputButton() {
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
extension VoiceCallViewController {
    func updateLocalAudio(enabled: Bool) {
        if enabled {
            self.muteAudioButton.setImage(UIImage.mutedAudioImage, for: .normal)
            call?.muteMicrophone()
        } else {
            self.muteAudioButton.setImage(UIImage.unmutedAudioImage, for: .normal)
            call?.unmuteMicrophone()
        }
    }
    
    func updateRemoteAudio(isOn: Bool) {
        DispatchQueue.main.async { [weak self] in
            if isOn {
                self?.profileImageView.alpha = 1.0
            } else {
                self?.profileImageView.alpha = 0.3
            }
        }
    }
    
    func activeTimer() {
        self.callTimerLabel.text = "00:00"
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let duration = Double(self.call.duration)
            
            let convertedTime = Int(duration / 1000)
            let hour = Int(convertedTime / 3600)
            let minute = Int(convertedTime / 60) % 60
            let second = Int(convertedTime % 60)
            
            // update UI
            let secondText = second < 10 ? "0\(second)" : "\(second)"
            let minuteText = minute < 10 ? "0\(minute)" : "\(minute)"
            let hourText = hour == 0 ? "" : "\(hour):"
            
            self.callTimerLabel.text = "\(hourText)\(minuteText):\(secondText)"
            
            // Timer Invalidate
            if self.call.endedAt != 0 {
                timer.invalidate()
            }
        }
    }
}


// MARK: - SendBirdCall - DirectCallDelegate
extension VoiceCallViewController: DirectCallDelegate {
    func didEstablish(_ call: DirectCall) {
        DispatchQueue.main.async { [weak self] in
            self?.callTimerLabel.text = "Connecting..."
        }
    }
    
    // This method is required
    func didConnect(_ call: DirectCall) {
        DispatchQueue.main.async {
            self.activeTimer()      // call.duration
            self.updateRemoteAudio(isOn: call.isRemoteAudioEnabled)
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
        DispatchQueue.main.async { [weak self] in
            self?.endButton.isEnabled = true
            self?.dismiss(animated: true, completion: nil)
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
        var imageName = "mic"
        switch outputType {
        case .airPlay: imageName = "airplayvideo"
        case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE: imageName = "headphones"
        case .builtInReceiver: imageName = "phone.fill"
        case .builtInSpeaker: imageName = "mic"
        case .headphones: imageName = "headphones"
        case .headsetMic: imageName = "headphones"
        default: imageName = "mic"
        }
        
        DispatchQueue.main.async { [weak self] in
            if #available(iOS 13.0, *) {
                self?.speakerButton.setBackgroundImage(nil, for: .normal)
                self?.speakerButton.setImage(UIImage(systemName: imageName), for: .normal)
            } else {
                self?.speakerButton.setBackgroundImage(UIImage(named: "icChatAudioPurple"), for: .normal)
            }
            
            let alert = UIAlertController(title: nil, message: "Changed to \(outputName)", preferredStyle: .actionSheet)
            self?.present(alert, animated: true, completion: nil)
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}


