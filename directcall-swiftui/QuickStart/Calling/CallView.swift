//
//  CallView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SendBirdCalls
import SwiftUI

/// The screen of an ongoing voice or video call.
struct CallView: View {
    let activeCall: ActiveCall

    var body: some View {
        if let call = SendBirdCall.getCall(forCallId: activeCall.callId) {
            CallScreen(call: call, isDialing: activeCall.isDialing)
        } else {
            // The call no longer exists, for example because it ended before this screen appeared.
            Color.black
                .ignoresSafeArea()
                .task { CallRouter.shared.dismiss(callId: activeCall.callId) }
        }
    }
}

private struct CallScreen: View {
    @State private var session: CallSession
    @State private var isEnding = false

    init(call: DirectCall, isDialing: Bool) {
        _session = State(initialValue: CallSession(call: call, isDialing: isDialing))
    }

    private var isVideoCall: Bool { session.call.isVideoCall }

    private var isEnded: Bool {
        if case .ended = session.status { return true }
        return false
    }

    private var isConnected: Bool {
        session.status == .connected || session.status == .reconnecting
    }

    var body: some View {
        ZStack {
            Color(white: 0.12)
                .ignoresSafeArea()
            if isVideoCall {
                videoLayer
            }
            VStack(spacing: 16) {
                if !isVideoCall || !isConnected || isEnded {
                    header
                }
                if isConnected && !session.isRemoteAudioEnabled {
                    remoteMutedLabel
                }
                Spacer()
                if !isEnded {
                    controls
                }
            }
            .padding(.vertical, 32)
            .foregroundStyle(.white)
        }
        .task { session.start() }
        .alert("Something went wrong",
               isPresented: Binding(get: { session.errorMessage != nil }, set: { if !$0 { session.errorMessage = nil } })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(session.errorMessage ?? "")
        }
    }

    // MARK: - Video

    /// Before the call is established, the local video fills the screen. Then it shrinks to a small preview.
    private var isLocalPreviewSmall: Bool { session.status != .waiting }

    private var videoLayer: some View {
        ZStack(alignment: .topLeading) {
            VideoView(call: session.call, source: .remote)
                .ignoresSafeArea()
                .opacity(isConnected ? 1 : 0)

            // Change the frame and opacity instead of adding or removing the view, so the video view stays the same.
            VideoView(call: session.call, source: .local)
                // Mirror the front camera, like a mirror.
                .scaleEffect(x: session.isUsingFrontCamera ? -1 : 1, y: 1)
                .frame(width: isLocalPreviewSmall ? 96 : nil, height: isLocalPreviewSmall ? 160 : nil)
                .frame(maxWidth: isLocalPreviewSmall ? nil : .infinity, maxHeight: isLocalPreviewSmall ? nil : .infinity)
                .clipShape(RoundedRectangle(cornerRadius: isLocalPreviewSmall ? 12 : 0))
                .padding(isLocalPreviewSmall ? 16 : 0)
                .ignoresSafeArea(edges: isLocalPreviewSmall ? [] : .all)
                .opacity(session.isLocalVideoEnabled && !isEnded ? 1 : 0)
                .animation(.easeOut(duration: 0.3), value: isLocalPreviewSmall)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            if !isVideoCall || isEnded {
                ProfileImage(url: session.call.remoteUser?.profileURL)
                    .frame(width: 80, height: 80)
                    .padding(.top, 48)
            }
            Text(session.remoteName)
                .font(.title2.bold())
            statusText
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var statusText: some View {
        switch session.status {
        case .waiting:
            Text("Calling...")
        case .connecting:
            Text("Connecting...")
        case .connected:
            // Redraws every second to show the call duration.
            TimelineView(.periodic(from: .now, by: 1)) { _ in
                Text(CallText.duration(milliseconds: session.call.duration))
                    .monospacedDigit()
            }
        case .reconnecting:
            Text("Reconnecting...")
        case .ended(let result):
            Text(CallText.endResult(result))
        }
    }

    private var remoteMutedLabel: some View {
        HStack(spacing: 8) {
            Image("iconAudioOff")
            Text("\(session.remoteName) is muted")
                .font(.footnote)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.black.opacity(0.4), in: Capsule())
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: 16) {
            Image(session.audioOutputImageName)
                .overlay { AudioRoutePicker() }
            Button {
                session.toggleAudio()
            } label: {
                Image(session.isLocalAudioEnabled ? "btnAudioOff" : "btnAudioOffSelected")
            }
            if isVideoCall {
                Button {
                    session.toggleVideo()
                } label: {
                    Image(session.isLocalVideoEnabled ? "btnVideoOff" : "btnVideoOffSelected")
                }
                Button {
                    session.switchCamera()
                } label: {
                    Image("btnCameraFlipIos")
                }
            }
            Button {
                isEnding = true
                session.end()
            } label: {
                Image("btnCallEnd")
            }
            .disabled(isEnding)
        }
    }
}

/// The profile image of a user, or a placeholder when there is none.
struct ProfileImage: View {
    let url: String?

    var body: some View {
        AsyncImage(url: url.flatMap(URL.init(string:))) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Image("iconAvatar").resizable().scaledToFill()
        }
        .clipShape(Circle())
    }
}
