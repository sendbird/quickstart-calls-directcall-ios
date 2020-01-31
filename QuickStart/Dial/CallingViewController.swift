//
//  CallingViewController.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation
import SendBirdCalls

class CallingViewController: UIViewController {
    
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
        self.callTimerLabel.text = "Waiting for connection ..."
        self.profileImageView.rounding()
        self.profileImageView.border()
        self.nameLabel.text = self.call.remoteUser?.userId
        self.updateRemoteAudio(isOn: self.call.isRemoteAudioEnabled)
        
        // Local Info
        let audioButtonImage = call.isLocalAudioEnabled ? UIImage.unmute() : UIImage.mute()
        self.muteAudioButton.isSelected = !self.call.isLocalAudioEnabled
        self.muteAudioButton.setImage(audioButtonImage, for: .normal)
        self.muteAudioButton.rounding()
        
        self.endButton.rounding()
        
        // AudioOutputs
        self.setAudioOutputsView()
        self.setupNotifications()
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

// MARK: - AudioOutputs
extension CallingViewController {
    
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.handleRouteChange(notification:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    @objc
    func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt else { return }
        guard let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        guard let outputType = audioSession.currentRoute.outputs.first?.portType else { return }
        guard let outputName = audioSession.currentRoute.outputs.first?.portName else { return }
        
        DispatchQueue.main.async {
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
            
            if #available(iOS 13.0, *) {
                self.speakerButton.setImage(UIImage(systemName: imageURL), for: .normal)
            }
            
            let alert = UIAlertController(title: nil, message: "Changed to \(outputName)", preferredStyle: .actionSheet)
            self.present(alert, animated: true, completion: nil)
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
                alert.dismiss(animated: true, completion: nil)
                timer.invalidate()
            }
        }
        
        print("\(reason)")
        print("\(audioSession.currentRoute.outputs)")
        print(audioSession.outputDataSource ?? "none")
    }
    
    func setAudioOutputsView() {
        self.speakerButton.rounding()
        self.speakerButton.layer.borderColor = UIColor.purple.cgColor
        self.speakerButton.layer.borderWidth = 2.0
        
        let audioOutputsView = AudioOutputsView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        
        audioOutputsView.showsVolumeSlider = false
        audioOutputsView.setRouteButtonImage(nil, for: .normal)
        
        self.speakerButton.addSubview(audioOutputsView)
    }
}

// MARK: - SendBirdCall - DirectCall duration & mute / unmute
extension CallingViewController {
    func updateLocalAudio(enabled: Bool) {
        if enabled {
            self.muteAudioButton.setImage(UIImage.mute(), for: .normal)
            call?.muteMicrophone()
        } else {
            self.muteAudioButton.setImage(UIImage.unmute(), for: .normal)
            call?.unmuteMicrophone()
        }
    }
    
    func updateRemoteAudio(isOn: Bool) {
        DispatchQueue.main.async {
            if isOn {
                self.profileImageView.alpha = 1.0
            } else {
                self.profileImageView.alpha = 0.3
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
extension CallingViewController: DirectCallDelegate {
    // This method is required
    func didConnect(_ call: DirectCall) {
        DispatchQueue.main.async {
            self.activeTimer()      // call.duration
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
}


