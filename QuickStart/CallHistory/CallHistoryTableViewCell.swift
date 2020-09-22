//
//  CallHistoryViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/29.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

class CallHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var callTypeImageView: UIImageView!
    
    @IBOutlet weak var remoteUserProfileImageView: UIImageView!
    
    @IBOutlet weak var remoteNicknameLabel: UILabel!
    @IBOutlet weak var remoteUserIDLabel: UILabel!
    @IBOutlet weak var startedAtLabel: UILabel!
    @IBOutlet weak var endResultLabel: UILabel!
    
    @IBOutlet weak var voiceCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
    
    typealias Event = ((CallHistory) -> Void)
    
    var tryVoiceCall: Event?
    var tryVideoCall: Event?
    
    var callHistory: CallHistory! {
        didSet {
            self.updateUI()
        }
    }
    
    func updateUI() {
        self.callTypeImageView.image = UIImage.callTypeImage(outgoing: self.callHistory.outgoing, hasVideo: self.callHistory.hasVideo)
        self.remoteUserProfileImageView.updateImage(urlString: self.callHistory.remoteUserProfileURL)
        
        self.remoteNicknameLabel.text = self.callHistory.remoteNickname
        self.remoteUserIDLabel.text = "User ID: " + self.callHistory.remoteUserID
        
        self.startedAtLabel.text = self.callHistory.startedAt
        self.endResultLabel.text = self.callHistory.endResult + " " + self.callHistory.duration
    }
    
    @IBAction func didTapVoiceCall() {
        guard self.callHistory.remoteUserID != "Unknown" else { return }
        self.tryVoiceCall?(self.callHistory)
    }
    
    @IBAction func didTapVideoCall() {
        guard self.callHistory.remoteUserID != "Unknown" else { return }
        self.tryVideoCall?(self.callHistory)
    }
}
