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

class VideoCallViewController: UIViewController, DirectCallDataSource {
    // Video Views
    @IBOutlet weak var localVideoView: UIView?
    
    // Labels
    @IBOutlet weak var callStatusLabel: UILabel!
    @IBOutlet weak var mutedStateLabel: UILabel!
    @IBOutlet weak var remoteUserIdLabel: UILabel!
    
    // ImageView
    @IBOutlet weak var mutedStateImageView: UIImageView!
    @IBOutlet weak var remoteProfileImageView: UIImageView! {
        didSet {
            let profileURL = self.call.remoteUser?.profileURL
            self.remoteProfileImageView.setImage(urlString: profileURL)
            self.remoteProfileImageView.isHidden = true
        }
    }
    
    // Buttons
    @IBOutlet weak var audioRouteButton: UIButton!
    @IBOutlet weak var audioOffButton: UIButton!
    @IBOutlet weak var videoOffButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    
    // Contstraints of local video view
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // Constraints of remote user ID
    @IBOutlet weak var topSpaceRemoteUserId: NSLayoutConstraint!
    
    var call: DirectCall!
    var isDialing: Bool?
    
    let callController = CXCallController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.call.delegate = self
        
        self.setupVideoView()
        self.setupUI()
        self.updateRemoteAudio(isEnabled: true)
        self.setupAudioOutputButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isDialing ?? false {
            guard let calleeId = self.call.remoteUser?.userId else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            self.startCXCall(to: calleeId)
        }
    }
    
    // MARK: - Basic UI
    func setupUI() {
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
            
        self.callStatusLabel.text = "Calling..."
        
        // Local video view full screen
        self.leadingConstraint.constant = 0
        self.trailingConstraint.constant = 0
        self.topConstraint.constant = -44
        self.bottomConstraint.constant = -44
        
        // Remote Info
        self.remoteUserIdLabel.text = self.call.remoteUser?.userId
        self.mutedStateLabel.text = "\(self.call.remoteUser?.userId ?? "Remote user") is on mute"
        
        // Local Info
        self.audioOffButton.isSelected = !self.call.isLocalAudioEnabled
    }
    
    func setupEndedCallUI() {
        // Tell user that the call has been ended.
        self.callStatusLabel.text = "Call Ended"
        self.topSpaceRemoteUserId.constant = 244
        self.callStatusLabel.isHidden = false
        self.remoteUserIdLabel.isHidden = false
        self.remoteProfileImageView.isHidden = false
        
        // Release resource
        self.view.subviews[0].removeFromSuperview()
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
            self.mirrorLocalVideoView()
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
        
        self.requestEndTransaction(of: call)
    }
    
    // MARK: - CallKit Methods
    func startCXCall(to calleeId: String) {
        
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

// MARK: - SendBirdCalls: Video Features
extension VideoCallViewController {
    func setupVideoView() {
        let localSBVideoView = SendBirdVideoView(frame: localVideoView?.frame ?? CGRect.zero)
        let remoteSBVideoView = SendBirdVideoView(frame: view?.frame ?? CGRect.zero)
        
        self.call.updateLocalVideoView(localSBVideoView)
        self.call.updateRemoteVideoView(remoteSBVideoView)
        
        self.localVideoView?.embed(localSBVideoView)
        self.view?.embed(remoteSBVideoView)
        
        self.mirrorLocalVideoView()
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
    
    func mirrorLocalVideoView() {
        guard let localSBView = self.localVideoView?.subviews.first else { return }
        localSBView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
    
    // SendBirdCalls: Start / Stop Video
    func updateLocalVideo(isEnabled: Bool) {
        self.videoOffButton.setBackgroundImage(UIImage(named: isEnabled ? "btnVideoOffSelected" : "btnVideoOff"), for: .normal)
        if isEnabled {
            call.stopVideo()
            self.localVideoView?.subviews[0].isHidden = true
        } else {
            call.startVideo()
            self.localVideoView?.subviews[0].isHidden = false
        }
    }
}

// MARK: - SendBirdCalls: Audio Features
extension VideoCallViewController {
    func updateLocalAudio(isEnabled: Bool) {
        self.audioOffButton.setBackgroundImage(UIImage(named: isEnabled ? "btnAudioOffSelected" : "btnAudioOff"), for: .normal)
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
        self.remoteUserIdLabel.isHidden = true
        self.callStatusLabel.isHidden = true
        self.updateRemoteAudio(isEnabled: call.isRemoteAudioEnabled)
    }
    
    func didEnd(_ call: DirectCall) {
        self.setupEndedCallUI()
        
        guard let enderId = call.endedBy?.userId, let myId = SendBirdCall.currentUser?.userId, enderId != myId else { return }
        guard let call = SendBirdCall.getCall(forCallId: self.call.callId) else { return }
        self.requestEndTransaction(of: call)
    }
    
    // MARK: Optional Methods
    func didEstablish(_ call: DirectCall) {
        self.resizeLocalVideoView()
        self.callStatusLabel.text = "Connecting..."
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
