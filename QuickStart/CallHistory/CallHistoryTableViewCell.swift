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
    func didStartVoiceCall(_ cell: CallHistoryTableViewCell, dialParams: DialParams)
    
    func didStartVideoCall(_ cell: CallHistoryTableViewCell, dialParams: DialParams)
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
    
    var directCallLog: DirectCallLog! {
        didSet {
            self.updateUI()
        }
    }
    
    weak var delegate: CallHistoryCellDelegate?
    
    func updateUI() {
        let callType = self.directCallLog.isVideoCall ? self.directCallLog.myRole == .caller ? "iconCallVideoOutgoingFilled" : "iconCallVideoIncomingFilled" : self.directCallLog.myRole == .callee ? "iconCallVoiceOutgoingFilled" : "iconCallVoiceIncomingFilled"
        let remoteUser = self.directCallLog.myRole == .caller ? self.directCallLog.callee : self.directCallLog.caller
        
        self.callTypeImageView.image = UIImage(named: callType)
        self.remoteUserProfileImageView.setImage(urlString: remoteUser?.profileURL)
        self.remoteUserIDLabel.text = remoteUser?.userId
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/d HH:mma"
        
        self.startedAtLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(self.directCallLog.startedAt) / 1000))
        self.callDurationLabel.text = self.directCallLog.duration.timerText()
        self.endResultLabel.text = self.directCallLog.endResult.rawValue
    }
    
    @IBAction func didTapVoiceCall() {
        guard let remoteUser = self.directCallLog.myRole == .caller ? self.directCallLog.callee : self.directCallLog.caller else { return }
        let callOptions = CallOptions(isAudioEnabled: true)
        let dialParams = DialParams(calleeId: remoteUser.userId, isVideoCall: false, callOptions: callOptions, customItems: [:])
        self.delegate?.didStartVoiceCall(self, dialParams: dialParams)
    }
    
    @IBAction func didTapVideoCall() {
        guard let remoteUser = self.directCallLog.myRole == .caller ? self.directCallLog.callee : self.directCallLog.caller else { return }
        let callOptions = CallOptions(isAudioEnabled: true, isVideoEnabled: true, localVideoView: nil, remoteVideoView: nil, useFrontCamera: true)
        let dialParams = DialParams(calleeId: remoteUser.userId, isVideoCall: false, callOptions: callOptions, customItems: [:])
        self.delegate?.didStartVideoCall(self, dialParams: dialParams)
    }
}

