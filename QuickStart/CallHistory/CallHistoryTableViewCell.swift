//
//  CallHistoryViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/29.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

protocol CallHistoryCellDelegate: class {
    // make voice call from call history
    func didTapVoiceCallButton(_ cell: CallHistoryTableViewCell, dialParams: DialParams)
    
    // make video call from call history
    func didTapVideoCallButton(_ cell: CallHistoryTableViewCell, dialParams: DialParams)
    
    func didTapCallHistoryCell(_ cell: CallHistoryTableViewCell)
}

class CallHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var callTypeImageView: UIImageView!
    
    @IBOutlet weak var remoteUserProfileImageView: UIImageView!
    
    @IBOutlet weak var remoteUserIDLabel: UILabel!
    @IBOutlet weak var startedAtLabel: UILabel!
    @IBOutlet weak var callDurationLabel: UILabel!
    @IBOutlet weak var endResultLabel: UILabel!
    
    @IBOutlet weak var voiceCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
    
    var callHistory: CallHistory! {
        didSet {
            self.updateUI()
        }
    }
    
    weak var delegate: CallHistoryCellDelegate?
    
    func updateUI() {
        let callType = self.callHistory.callTypeImageURL
        
        self.callTypeImageView.image = UIImage(named: callType)
        self.remoteUserProfileImageView.updateImage(urlString: self.callHistory.remoteUserProfileURL)
        
        self.remoteUserIDLabel.text = self.callHistory.remoteUserID
        
        self.startedAtLabel.text = self.callHistory.startedAt
        self.callDurationLabel.text = self.callHistory.duration
        self.endResultLabel.text = self.callHistory.endResult
    }
    
    @IBAction func didTapVoiceCall() {
        guard self.callHistory.remoteUserID != "Unknown" else { return }
        let callOptions = CallOptions(isAudioEnabled: true)
        let dialParams = DialParams(calleeId: self.callHistory.remoteUserID,
                                    isVideoCall: false,
                                    callOptions: callOptions,
                                    customItems: [:])
        self.delegate?.didTapVoiceCallButton(self, dialParams: dialParams)
    }
    
    @IBAction func didTapVideoCall() {
        guard self.callHistory.remoteUserID != "Unknown" else { return }
        let callOptions = CallOptions(isAudioEnabled: true, isVideoEnabled: true, localVideoView: nil, remoteVideoView: nil, useFrontCamera: true)
        let dialParams = DialParams(calleeId: self.callHistory.remoteUserID,
                                    isVideoCall: true,
                                    callOptions: callOptions,
                                    customItems: [:])
        self.delegate?.didTapVideoCallButton(self, dialParams: dialParams)
    }
}

