//
//  CallHistory.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import Foundation
import SendBirdCalls

/// One row of the call history.
struct CallHistory: Codable, Identifiable, Equatable {
    /// The call ID.
    let id: String
    let isOutgoing: Bool
    let hasVideo: Bool
    let remoteUserId: String
    let remoteNickname: String
    let remoteProfileURL: String?
    /// Milliseconds since 1970.
    let startedAt: Int64
    /// Milliseconds.
    let duration: Int64
    /// For example, `Completed` or `No answer`.
    let endResult: String
}

extension CallHistory {
    init(callLog: DirectCallLog) {
        let remoteUser = callLog.myRole == .caller ? callLog.callee : callLog.caller
        let nickname = remoteUser?.nickname ?? ""
        self.init(
            id: callLog.callId,
            isOutgoing: callLog.myRole == .caller,
            hasVideo: callLog.isVideoCall,
            remoteUserId: remoteUser?.userId ?? "Unknown",
            remoteNickname: nickname.isEmpty ? "-" : nickname,
            remoteProfileURL: remoteUser?.profileURL,
            startedAt: callLog.startedAt,
            duration: callLog.duration,
            endResult: CallText.endResult(callLog.endResult)
        )
    }

    /// For example, `2025/12/29 09:41`. Uses the calendar year (`yyyy`), not the week-based year (`YYYY`).
    static func formatStartedAt(_ milliseconds: Int64, timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.timeZone = timeZone
        return formatter.string(from: Date(timeIntervalSince1970: Double(milliseconds) / 1000))
    }

    var startedAtText: String { Self.formatStartedAt(startedAt) }

    /// For example, `Completed · 01:05`.
    var resultText: String { "\(endResult) · \(CallText.duration(milliseconds: duration))" }

    /// The icon for the call direction and type.
    var callTypeImageName: String {
        switch (isOutgoing, hasVideo) {
        case (true, false): return "iconCallVoiceOutgoingFilled"
        case (true, true): return "iconCallVideoOutgoingFilled"
        case (false, false): return "iconCallVoiceIncomingFilled"
        case (false, true): return "iconCallVideoIncomingFilled"
        }
    }
}
