//
//  VideoCallViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/11.
//  Copyright © 2020 Sendbird Inc. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import CallKit
import AVFoundation
import SendBirdCalls

class VideoCallViewController: UIViewController, DirectCallDataSource {
    // Video Views
    @IBOutlet weak var localVideoView: UIView?
    
    // Labels
    @IBOutlet weak var callStatusLabel: UILabel!
    @IBOutlet weak var mutedStateLabel: UILabel! {
        didSet {
            guard let remoteUser = self.call.remoteUser else { return }
            let name = remoteUser.nickname?.isEmptyOrWhitespace == true ? remoteUser.userId : remoteUser.nickname!
            self.mutedStateLabel.text = CallStatus.muted(user: name).message
        }
    }
    @IBOutlet weak var remoteNicknameLabel: UILabel! {
        didSet {
            let nickname = self.call.remoteUser?.nickname
            self.remoteNicknameLabel.text = nickname?.isEmptyOrWhitespace == true ? self.call.remoteUser?.userId : nickname
        }
    }
    
    // ImageView
    @IBOutlet weak var mutedStateImageView: UIImageView!
    @IBOutlet weak var remoteProfileImageView: UIImageView! {
        didSet {
            let profileURL = self.call.remoteUser?.profileURL
            self.remoteProfileImageView.isHidden = true
            self.remoteProfileImageView.updateImage(urlString: profileURL)
        }
    }
    
    // Buttons
    @IBOutlet weak var audioRouteButton: UIButton!
    @IBOutlet weak var audioOffButton: UIButton! {
        didSet {
            self.audioOffButton.isSelected = !self.call.isLocalAudioEnabled
        }
    }
    @IBOutlet weak var videoOffButton: UIButton! {
        didSet {
            self.videoOffButton.isSelected = !self.call.isLocalVideoEnabled
        }
    }
    @IBOutlet weak var endButton: UIButton!
    
    // Contstraints of local video view
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint! {
        didSet {
            self.leadingConstraint.constant = 0
        }
    }
    @IBOutlet weak var topConstraint: NSLayoutConstraint! {
        didSet {
            self.topConstraint.constant = -44
        }
    }
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint! {
        didSet {
            self.trailingConstraint.constant = 0
        }
    }
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! {
        didSet {
            self.bottomConstraint.constant = -44
        }
    }
    
    // Constraints of remote user ID
    @IBOutlet weak var topSpaceRemoteNickname: NSLayoutConstraint!
    
    var call: DirectCall!
    var isDialing: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
        self.call.delegate = self
        
        self.setupVideoView()
        self.updateRemoteAudio(isEnabled: true)
        self.setupAudioOutputButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard self.isDialing == true else { return }
        CXCallManager.shared.startCXCall(self.call) { [weak self] isSuccess in
            guard let self = self else { return }
            if !isSuccess {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }  
    
    // MARK: - Basic UI
    func setupEndedCallUI() {
        // Tell user that the call has been ended.
        self.callStatusLabel.text = CallStatus.ended(result: call.endResult.rawValue).message
        self.topSpaceRemoteNickname.constant = 244
        self.callStatusLabel.isHidden = false
        self.remoteNicknameLabel.isHidden = false
        self.remoteProfileImageView.isHidden = false
        
        // Release resource
        self.view.subviews.first?.removeFromSuperview()
        self.localVideoView?.isHidden = true
        self.mutedStateImageView.isHidden = true
        self.mutedStateLabel.isHidden = true
        
        self.endButton.isHidden = true
        self.audioOffButton.isHidden = true
        self.videoOffButton.isHidden = true
        self.audioRouteButton.isHidden = true
        
        // Go back to `Dial` view
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - IBActions
    @IBAction func didTapFilpCamera() {
        let availableCapturers = self.call.availableVideoDevices
        guard let oppositeCamera = availableCapturers.first(where: { $0.position != self.call.currentVideoDevice?.position }) else {
            self.presentErrorAlert(message: "Failed to flip camera. Please retry.")
            return
        }
        self.call.selectVideoDevice(oppositeCamera) { error in
            guard error == nil else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.presentErrorAlert(message: error?.localizedDescription ?? "")
                }
                return
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch oppositeCamera.position {
                case .front: self.mirrorLocalVideoView(isEnabled: true)
                case .back: self.mirrorLocalVideoView(isEnabled: false)
                default: return
                }
            }
        }
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
        
        CXCallManager.shared.endCXCall(call)
    }
}

// MARK: - SendBirdCall: Video Features
extension VideoCallViewController {
    func setupVideoView() {
        let localSBVideoView = SendBirdVideoView(frame: localVideoView?.frame ?? CGRect.zero)
        let remoteSBVideoView = SendBirdVideoView(frame: view?.frame ?? CGRect.zero)
        
        self.call.updateLocalVideoView(localSBVideoView)
        self.call.updateRemoteVideoView(remoteSBVideoView)
        
        self.localVideoView?.embed(localSBVideoView)
        self.view?.embed(remoteSBVideoView)
        
        self.mirrorLocalVideoView(isEnabled: true)
    }
    
    func resizeLocalVideoView() {
        // Local video view: full screen -> left upper corner small screen
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            var topSafeMargin: CGFloat = 0
            var bottomSafeMarging: CGFloat = 0
            if #available(iOS 11.0, *) {
                topSafeMargin = self.view.safeAreaInsets.top
                bottomSafeMarging = self.view.safeAreaInsets.bottom
            }
            // Resize as width: 96, height: 160
            self.leadingConstraint.constant = 16
            self.trailingConstraint.constant = self.view.frame.width - 112 // (leadingConstraint + local video view width)
            self.topConstraint.constant = 16
            self.bottomConstraint.constant = self.view.frame.maxY - (topSafeMargin + bottomSafeMarging) - 176 // (topConstraint + video view height)
            self.view.layoutIfNeeded()
        })
    }
    
    func mirrorLocalVideoView(isEnabled: Bool) {
        guard let localSBView = self.localVideoView?.subviews.first else { return }
        switch isEnabled {
        case true: localSBView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        case false: localSBView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    // MARK: SendBirdCall: Start / Stop Video
    func updateLocalVideo(isEnabled: Bool) {
        self.videoOffButton.setBackgroundImage(.video(isOn: isEnabled),
                                               for: .normal)
        if isEnabled {
            call.stopVideo()
            self.localVideoView?.subviews.first?.isHidden = true
        } else {
            call.startVideo()
            self.localVideoView?.subviews.first?.isHidden = false
        }
    }
}

// MARK: - SendBirdCall: Audio Features
extension VideoCallViewController {
    func updateLocalAudio(isEnabled: Bool) {
        self.audioOffButton.setBackgroundImage(.audio(isOn: isEnabled), for: .normal)
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

// MARK: - SendBirdCall: Audio Output
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

// MARK: - SendBirdCall: DirectCallDelegate
// Delegate methods are executed on Main thread

extension VideoCallViewController: DirectCallDelegate {
    // MARK: Required Methods
    func didConnect(_ call: DirectCall) {
        self.remoteNicknameLabel.isHidden = true
        self.callStatusLabel.isHidden = true
        self.updateRemoteAudio(isEnabled: call.isRemoteAudioEnabled)

        CXCallManager.shared.connectedCall(call)
    }
    
    func didEnd(_ call: DirectCall) {
        DispatchQueue.main.async {
            guard let callLog = call.callLog else { return }
            UserDefaults.standard.callHistories.insert(CallHistory(callLog: callLog), at: 0)
            
            CallHistoryViewController.main?.updateCallHistories()
        }
        
        self.setupEndedCallUI()
        
        guard let enderId = call.endedBy?.userId, let myId = SendBirdCall.currentUser?.userId, enderId != myId else { return }
        guard let call = SendBirdCall.getCall(forCallId: self.call.callId) else { return }
        CXCallManager.shared.endCXCall(call)
    }
    
    // MARK: Optional Methods
    func didEstablish(_ call: DirectCall) {
        self.resizeLocalVideoView()
        self.callStatusLabel.text = CallStatus.connecting.message
    }
    
    func didRemoteAudioSettingsChange(_ call: DirectCall) {
        self.updateRemoteAudio(isEnabled: call.isRemoteAudioEnabled)
    }
    
    func didRemoteVideoSettingsChange(_ call: DirectCall) {
        // ...
    }
    
    func didAudioDeviceChange(_ call: DirectCall, session: AVAudioSession, previousRoute: AVAudioSessionRouteDescription, reason: AVAudioSession.RouteChangeReason) {
        guard !call.isEnded else { return }
        guard let output = session.currentRoute.outputs.first else { return }
        
        self.audioRouteButton.setBackgroundImage(.audio(output: output.portType),
                                                 for: .normal)
        print("[QuickStart] Audio Route has been changed to \(output.portName)")
        
        // Disable to display `AVAudioPickerView` (also `MPVolumeView`) when it is speaker mode.
        self.audioRouteButton.isEnabled = output.portType != .builtInSpeaker
    }
}
