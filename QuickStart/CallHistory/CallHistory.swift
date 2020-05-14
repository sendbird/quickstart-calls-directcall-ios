//
//  CallHistory.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/05/14.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import Foundation

struct CallHistory: Codable {
    let callTypeImageURL: String
    let remoteUserProfileURL: String?
    let remoteUserID: String
    let duration: String
    let endResult: String
    let startedAt: String
    
    static func fetchAll() -> [CallHistory] {
        return UserDefaults.standard.callHistories
    }
}

import SendBirdCalls

extension DirectCallLog {
    func convertToCallHistory() -> CallHistory {
        
        let callType = self.isVideoCall ? self.myRole == .caller ? "iconCallVideoOutgoingFilled" : "iconCallVideoIncomingFilled" : self.myRole == .callee ? "iconCallVoiceOutgoingFilled" : "iconCallVoiceIncomingFilled"
        
        let remoteUser = self.myRole == .caller ? self.callee : self.caller
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/d HH:mm"
        
        let startedAtText = dateFormatter.string(from: Date(timeIntervalSince1970: Double(self.startedAt) / 1000))
        let callDuration = self.duration.timerText()
        let endResultText = self.endResult.rawValue
        
        let history = CallHistory(callTypeImageURL: callType,
                                  remoteUserProfileURL: remoteUser?.profileURL,
                                  remoteUserID: remoteUser?.userId ?? "Unknown",
                                  duration: callDuration,
                                  endResult: endResultText,
                                  startedAt: startedAtText)
        return history
    }
}
