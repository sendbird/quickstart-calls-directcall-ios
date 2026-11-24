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
            Theme.callBackground
                .ignoresSafeArea()
                .task { CallRouter.shared.dismiss(callId: activeCall.callId) }
        }
    }
}

private struct CallScreen: View {
    // `SwiftUI.State`, not `State`: SendBirdCalls also has types named `State` (`Room.State`, `Participant.State`),
    // and some Xcode versions, such as Xcode 26, report `State` as ambiguous in files that import both modules.
    @SwiftUI.State private var session: CallSession
    @SwiftUI.State private var isEnding = false

    init(call: DirectCall, isDialing: Bool) {
        _session = SwiftUI.State(initialValue: CallSession(call: call, isDialing: isDialing))
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
        ZStack(alignment: .top) {
            Theme.callBackground
                .ignoresSafeArea()
            if isVideoCall {
                videoLayer
            }
            VStack(spacing: 0) {
                if isVideoCall {
                    switchCameraButton
                }
                header
                remoteMutedState
                Spacer()
                controls
            }
            .padding(.bottom, 64)
        }
        .task { session.start() }
        .errorAlert($session.errorMessage)
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
                // Covers the video while the camera switches. See `CallSession.switchCamera()`.
                // Only this cover fades. The mirroring above changes at once, while the cover hides it.
                .overlay {
                    Theme.localVideoBackground
                        .opacity(session.isSwitchingCamera ? 1 : 0)
                        .animation(.easeInOut(duration: 0.15), value: session.isSwitchingCamera)
                }
                .background(Theme.localVideoBackground)
                .clipShape(RoundedRectangle(cornerRadius: isLocalPreviewSmall ? 8 : 0))
                .padding(.leading, isLocalPreviewSmall ? 16 : 0)
                .padding(.top, isLocalPreviewSmall ? 16 : 0)
                .ignoresSafeArea(edges: isLocalPreviewSmall ? [] : .all)
                .opacity(session.isLocalVideoEnabled && !isEnded ? 1 : 0)
                .animation(.easeOut(duration: 0.3), value: isLocalPreviewSmall)
        }
    }

    private var switchCameraButton: some View {
        HStack {
            Spacer()
            Button {
                session.switchCamera()
            } label: {
                Image("btnCameraFlipIos")
                    .resizable()
                    .frame(width: 48, height: 48)
            }
            .disabled(session.isSwitchingCamera)
        }
        .padding(.top, 16)
        .padding(.trailing, 24)
        .opacity(isEnded ? 0 : 1)
    }

    // MARK: - Header

    /// The other user and the call status. A video call shows them only until the call connects, and after it ends.
    private var header: some View {
        let showsHeader = !isVideoCall || !isConnected
        let showsProfile = !isVideoCall || isEnded
        return VStack(spacing: 0) {
            if showsProfile {
                ProfileImage(url: session.call.remoteUser?.profileURL)
                    .frame(width: 80, height: 80)
                    .padding(.bottom, 24)
            }
            Text(session.remoteName)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
            statusText
                .font(.system(size: 17))
                .foregroundStyle(.white.opacity(0.88))
                .padding(.top, 8)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.top, isVideoCall ? 76 : 140)
        .opacity(showsHeader ? 1 : 0)
    }

    @ViewBuilder
    private var statusText: some View {
        switch session.status {
        case .waiting:
            Text("calling...")
        case .connecting:
            Text("call connecting...")
        case .connected:
            // Redraws every second to show the call duration.
            TimelineView(.periodic(from: .now, by: 1)) { _ in
                Text(CallText.duration(milliseconds: session.call.duration))
                    .monospacedDigit()
            }
        case .reconnecting:
            Text("reconnecting...")
        case .ended(let result):
            Text(CallText.endResult(result))
        }
    }

    private var remoteMutedState: some View {
        VStack(spacing: 16) {
            Image("iconAudioOff")
                .resizable()
                .frame(width: 40, height: 40)
            Text("\(session.remoteName) is muted")
                .font(.system(size: 17))
                .foregroundStyle(.white.opacity(0.88))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .opacity(isConnected && !session.isRemoteAudioEnabled ? 1 : 0)
    }

    // MARK: - Controls

    private var controls: some View {
        VStack(spacing: 24) {
            HStack(spacing: isVideoCall ? 24 : 40) {
                Button {
                    session.toggleAudio()
                } label: {
                    controlImage(session.isLocalAudioEnabled ? "btnAudioOff" : "btnAudioOffSelected")
                }
                if isVideoCall {
                    Button {
                        session.toggleVideo()
                    } label: {
                        controlImage(session.isLocalVideoEnabled ? "btnVideoOff" : "btnVideoOffSelected")
                    }
                }
                controlImage(session.audioOutputImageName)
                    .overlay { AudioRoutePicker() }
            }
            Button {
                isEnding = true
                session.end()
            } label: {
                controlImage("btnCallEnd")
            }
            .disabled(isEnding)
        }
        // The controls disappear when the call ends, but keep their space so that nothing else moves.
        .opacity(isEnded ? 0 : 1)
        .disabled(isEnded)
    }

    private func controlImage(_ name: String) -> some View {
        Image(name)
            .resizable()
            .frame(width: 64, height: 64)
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
