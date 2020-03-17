//
//  CallViewable.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/18.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

protocol CallViewable {
    // MARK: - Audio
    func updateLocalAudio(isEnabled: Bool)
    
    func updateRemoteAudio(isEnabled: Bool, call: DirectCall, in viewController: UIViewController)
    
    // MARK: - Video
    func updateLocalVideo(isEnabled: Bool)
    
    func updateRemoteVideo(isEnabled: Bool, in videoVC: VideoCallViewController)
    
    func resizeLocalVideoView(in videoVC: VideoCallViewController)
    
    // MARK: - Common
    func setupUI(in viewController: UIViewController)
    
    func setupEstabilshedCallUI(in viewController: UIViewController)
    
    func setupEndedCallUI(in viewController: UIViewController)
}

extension CallViewable {
    // MARK: - Audio
    func updateRemoteAudio(isEnabled: Bool, call: DirectCall, in viewController: UIViewController) {
        if let voiceCallVC = viewController as? VoiceCallViewController {
            voiceCallVC.mutedStateImageView.isHidden = isEnabled
            voiceCallVC.mutedStateLabel.isHidden = isEnabled
        } else if let videoCallVC = viewController as? VideoCallViewController {
            videoCallVC.mutedStateImageView.isHidden = isEnabled
            videoCallVC.mutedStateLabel.isHidden = isEnabled
        } else { return }
        
    }
    
    // MARK: - Video
    func updateLocalVideo(isEnabled: Bool) { }
    
    func updateRemoteVideo(isEnabled: Bool, in videoVC: VideoCallViewController) {
        videoVC.remoteProfileImageView.isHidden = isEnabled
    }
    
    func resizeLocalVideoView(in videoVC: VideoCallViewController) {
        // Local video view: full screen -> left upper corner small screen
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            var topSafeMargin: CGFloat = 0
            var bottomSafeMarging: CGFloat = 0
            if #available(iOS 11.0, *) {
                topSafeMargin = videoVC.view.safeAreaInsets.top
                bottomSafeMarging = videoVC.view.safeAreaInsets.bottom
            }
            
            // Resize as width: 96, height: 160
            videoVC.leadingConstraint.constant = 16
            videoVC.trailingConstraint.constant = videoVC.view.frame.width - 112 // (leadingConstraint + local video view width)
            videoVC.topConstratin.constant = 16
            videoVC.bottomConstraint.constant = videoVC.view.frame.height - (topSafeMargin + bottomSafeMarging) - 176 // (topConstraint + video view height)
            videoVC.view.layoutIfNeeded()
        })
    }
    
    // MARK: - Common
    func setupUI(in viewController: UIViewController) {
        viewController.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            viewController.isModalInPresentation = true
        }
        
        if let voiceCallVC = viewController as? VoiceCallViewController {
            // Remote Info
            voiceCallVC.callTimerLabel.text = "Calling..."
            let profileURL = voiceCallVC.call.remoteUser?.profileURL
            voiceCallVC.profileImageView.setImage(urlString: profileURL)
            voiceCallVC.nameLabel.text = voiceCallVC.call.remoteUser?.userId
            if let calleeId = voiceCallVC.call.callee?.userId {
                voiceCallVC.mutedStateLabel.text = "\(calleeId) muted this call"
            }

            // Local Info
            voiceCallVC.muteAudioButton.isSelected = !voiceCallVC.call.isLocalAudioEnabled
        } else if let videoCallVC = viewController as? VideoCallViewController {
            videoCallVC.callStatusLabel.text = "Calling..."
            
            // Local video view full screen
            videoCallVC.leadingConstraint.constant = 0
            videoCallVC.trailingConstraint.constant = 0
            videoCallVC.topConstratin.constant = -44
            videoCallVC.bottomConstraint.constant = -44
            
            // Remote Info
            let profileURL = videoCallVC.call.remoteUser?.profileURL
            videoCallVC.remoteProfileImageView.setImage(urlString: profileURL)
            videoCallVC.remoteProfileImageView.alpha = 0.7
            
            videoCallVC.remoteUserIdLabel.text = videoCallVC.call.remoteUser?.userId
            
            // Local Info
            videoCallVC.audioOffButton.isSelected = !videoCallVC.call.isLocalAudioEnabled
            
        } else { return }
    }
    
    func setupEstabilshedCallUI(in viewController: UIViewController) {
        if let voiceCallVC = viewController as? VoiceCallViewController {
            voiceCallVC.callTimerLabel.text = "Connecting..."
        } else if let videoCallVC = viewController as? VideoCallViewController {
            videoCallVC.callStatusLabel.text = "Connecting..."
            videoCallVC.remoteProfileImageView.isHidden = true
        } else { return }
    }
    
    func setupEndedCallUI(in viewController: UIViewController) {
        if let voiceCallVC = viewController as? VoiceCallViewController {
            voiceCallVC.callTimer?.invalidate()
            voiceCallVC.callTimerLabel.text = "Ended"
            
            voiceCallVC.endButton.isHidden = true
            voiceCallVC.speakerButton.isHidden = true
            voiceCallVC.muteAudioButton.isHidden = true
            voiceCallVC.videoCallButton.isHidden = true
            
            voiceCallVC.mutedStateImageView.isHidden = true
            voiceCallVC.mutedStateLabel.isHidden = true
        } else if let videoCallVC = viewController as? VideoCallViewController {
            // Tell user that the call has been ended.
            videoCallVC.callStatusLabel.text = "Ended"
            videoCallVC.callStatusLabel.isHidden = false
            videoCallVC.remoteUserIdLabel.isHidden = false
            
            // Release resource
            videoCallVC.view.subviews[0].removeFromSuperview()
            videoCallVC.localVideoView?.isHidden = true
            videoCallVC.remoteProfileImageView.isHidden = false
            videoCallVC.mutedStateImageView.isHidden = true
            videoCallVC.mutedStateLabel.isHidden = true
            
            videoCallVC.endButton.isHidden = true
            videoCallVC.audioOffButton.isHidden = true
            videoCallVC.videoOffButton.isHidden = true
            videoCallVC.audioRouteButton.isHidden = true
        } else { return }
        
        // Go back to `Dial` view
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            viewController.dismiss(animated: true, completion: nil)
        }
    }
}
