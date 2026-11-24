//
//  VideoView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SendBirdCalls
import SwiftUI

/// Shows the local or remote video of a call.
///
/// The `SendBirdVideoView` is created and given to the call only once, in `makeUIView(context:)`.
/// SwiftUI calls `updateUIView(_:context:)` whenever the screen redraws, so creating a new view there
/// would make the video flicker or stop. To hide the video, change its opacity instead of removing the view.
struct VideoView: UIViewRepresentable {
    enum Source {
        case local
        case remote
    }

    let call: DirectCall
    let source: Source

    func makeUIView(context: Context) -> SendBirdVideoView {
        let videoView = SendBirdVideoView()
        switch source {
        case .local:
            call.updateLocalVideoView(videoView)
        case .remote:
            call.updateRemoteVideoView(videoView)
        }
        return videoView
    }

    func updateUIView(_ videoView: SendBirdVideoView, context: Context) { }
}
