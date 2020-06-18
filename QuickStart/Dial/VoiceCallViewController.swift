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

class VoiceCallViewController: UIViewController, DirectCallDataSource {
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            let profileURL = self.call.remoteUser?.profileURL
            self.profileImageView.updateImage(urlString: profileURL)
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            self.nameLabel.text = self.call.remoteUser?.userId
        }
    }
    
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var muteAudioButton: UIButton! {
        didSet {
            self.muteAudioButton.isSelected = !self.call.isLocalAudioEnabled
        }
    }
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var callTimerLabel: UILabel!
    
    // Notify muted state
    @IBOutlet weak var mutedStateImageView: UIImageView!
    @IBOutlet weak var mutedStateLabel: UILabel! {
        didSet {
            self.mutedStateLabel.text = "\(self.call.remoteUser?.userId ?? "Remote user") is on mute"
        }
    }
    
    var call: DirectCall!
    var isDialing: Bool?
    
    var callTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        self.call.delegate = self
        
        self.setupAudioOutputButton()
        self.updateRemoteAudio(isEnabled: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard self.isDialing == true else { return }
        CXCallManager.shared.startCXCall(self.call) { [weak self] isSucceed in
            guard let self = self else { return }
            if !isSucceed {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    // MARK: - IBActions
    @IBAction func didTapAudioOption(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.updateLocalAudio(isEnabled: sender.isSelected)
    }
    
    @IBAction func didTapEnd() {
        self.endButton.isEnabled = false
        
        guard let call = SendBirdCall.getCall(forCallId: self.call.callId) else { return }
        call.end()
        CXCallManager.shared.endCXCall(call)
    }
    
    // MARK: - Basic UI
    func setupEndedCallUI() {
        self.callTimer?.invalidate()    // Main thread
        self.callTimer = nil
        self.callTimerLabel.text = "Call ended"
        
        self.endButton.isHidden = true
        self.speakerButton.isHidden = true
        self.muteAudioButton.isHidden = true
        
        self.mutedStateImageView.isHidden = true
        self.mutedStateLabel.isHidden = true
    }
}

// MARK: - SendBirdCalls: Audio Features
extension VoiceCallViewController {
    func updateLocalAudio(isEnabled: Bool) {
        self.muteAudioButton.setBackgroundImage(.audio(on: isEnabled), for: .normal)
        if isEnabled {
            call?.muteMicrophone()
        } else {
            call?.unmuteMicrophone()
        }
    }
    
    func updateRemoteAudio(isEnabled: Bool) {
        self.mutedStateImageView.isHidden = isEnabled
        self.mutedStateLabel.isHidden = isEnabled
    }
}

// MARK: - SendBirdCalls: Audio Output
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

// MARK: - SendBirdCalls: DirectCall duration
extension VoiceCallViewController {
    func activeTimer() {
        self.callTimerLabel.text = "00:00"
        
        // Main thread
        self.callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            // update UI
            self.callTimerLabel.text = self.call.duration.timerText()

            // Timer Invalidate
            if self.call.endedAt != 0, timer.isValid {
                timer.invalidate()
                self.callTimer = nil
            }
        }
    }
}

// MARK: - SendBirdCalls: DirectCallDelegate
// Delegate methods are executed on Main thread

extension VoiceCallViewController: DirectCallDelegate {
    // MARK: Required Methods
    func didConnect(_ call: DirectCall) {
        self.activeTimer()      // call.duration
        self.updateRemoteAudio(isEnabled: call.isRemoteAudioEnabled)
      
        CXCallManager.shared.connectedCall(call)
    }
    
    func didEnd(_ call: DirectCall) {
        self.setupEndedCallUI()
        
        DispatchQueue.main.async {
            guard let callLog = call.callLog else { return }
            UserDefaults.standard.callHistories.insert(CallHistory(callLog: callLog), at: 0)
            
            CallHistoryViewController.shared?.updateCallHistories()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        }
        
        guard let enderId = call.endedBy?.userId, let myId = SendBirdCall.currentUser?.userId, enderId != myId else { return }
        guard let call = SendBirdCall.getCall(forCallId: self.call.callId) else { return }
        CXCallManager.shared.endCXCall(call)
    }
    
    // MARK: Optional Methods
    func didEstablish(_ call: DirectCall) {
        self.callTimerLabel.text = "Connecting..."
    }
    
    func didRemoteAudioSettingsChange(_ call: DirectCall) {
        self.updateRemoteAudio(isEnabled: call.isRemoteAudioEnabled)
    }
    
    func didAudioDeviceChange(_ call: DirectCall, session: AVAudioSession, previousRoute: AVAudioSessionRouteDescription, reason: AVAudioSession.RouteChangeReason) {
        guard !call.isEnded else { return }
        guard let output = session.currentRoute.outputs.first else { return }
        
        self.speakerButton.setBackgroundImage(.audio(output: output.portType),
                                                 for: .normal)
        print("[QuickStart] Audio Route has been changed to \(output.portName)")
    }
}
