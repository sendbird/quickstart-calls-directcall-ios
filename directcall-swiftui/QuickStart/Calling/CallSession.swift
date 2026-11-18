//
//  CallSession.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import AVFoundation
import Foundation
import Observation
import SendBirdCalls

/// Publishes the state of one `DirectCall` to the call screen and performs the user's actions on it.
///
/// While the call screen is open, this object is the call's `delegate`. Before that, `CallEventHandler` is.
@MainActor
@Observable
final class CallSession: NSObject {
    enum Status: Equatable {
        /// Dialing or ringing. The call is not established yet.
        case waiting
        /// Both users accepted, and the media connection is being set up.
        case connecting
        case connected
        case reconnecting
        case ended(DirectCallEndResult)
    }

    let call: DirectCall
    private let isDialing: Bool
    private var hasStarted = false

    private(set) var status: Status = .waiting
    private(set) var isLocalAudioEnabled: Bool
    private(set) var isLocalVideoEnabled: Bool
    private(set) var isRemoteAudioEnabled = true
    private(set) var isRemoteVideoEnabled: Bool
    private(set) var isUsingFrontCamera = true
    private(set) var audioOutputImageName: String
    var errorMessage: String?

    init(call: DirectCall, isDialing: Bool) {
        self.call = call
        self.isDialing = isDialing
        self.isLocalAudioEnabled = call.isLocalAudioEnabled
        self.isLocalVideoEnabled = call.isLocalVideoEnabled
        self.isRemoteVideoEnabled = call.isRemoteVideoEnabled
        let output = AVAudioSession.sharedInstance().currentRoute.outputs.first?.portType ?? .builtInReceiver
        self.audioOutputImageName = CallText.audioOutputImageName(for: output)
        super.init()
    }

    var remoteName: String {
        guard let user = call.remoteUser else { return "Unknown" }
        if let nickname = user.nickname, !nickname.trimmingCharacters(in: .whitespaces).isEmpty {
            return nickname
        }
        return user.userId
    }

    /// Called once when the call screen appears.
    ///
    /// The delegate is set here, not in `init`, because SwiftUI can create a view's initial state more than once
    /// and only the one it keeps should receive the call's events.
    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        // From now on, this session receives the call's events instead of `CallEventHandler`.
        call.delegate = self

        if call.isEnded {
            didEnd(call)
            return
        }
        // Report an outgoing call to CallKit so that it keeps running in the background and shows in Recents.
        if isDialing {
            CallKitManager.shared.startCall(call)
        }
    }

    // MARK: - User actions

    func toggleAudio() {
        if call.isLocalAudioEnabled {
            call.muteMicrophone()
        } else {
            call.unmuteMicrophone()
        }
        isLocalAudioEnabled = call.isLocalAudioEnabled
    }

    func toggleVideo() {
        if call.isLocalVideoEnabled {
            call.stopVideo()
        } else {
            call.startVideo()
        }
        isLocalVideoEnabled = call.isLocalVideoEnabled
    }

    func switchCamera() {
        let currentPosition = call.currentVideoDevice?.position
        guard let device = call.availableVideoDevices.first(where: { $0.position != currentPosition }) else {
            errorMessage = "Failed to switch the camera. Try again."
            return
        }
        call.selectVideoDevice(device) { [weak self] error in
            guard let self else { return }
            if let error {
                self.errorMessage = error.localizedDescription
                return
            }
            self.isUsingFrontCamera = device.position == .front
        }
    }

    func end() {
        call.end()
        // Tell CallKit too, so that the system call UI ends.
        CallKitManager.shared.endCall(call)
    }
}

// MARK: - DirectCallDelegate

// Sendbird Calls calls the delegate on the main queue by default, so the main-actor methods below are safe.
extension CallSession: @preconcurrency DirectCallDelegate {
    func didEstablish(_ call: DirectCall) {
        status = .connecting
    }

    func didConnect(_ call: DirectCall) {
        status = .connected
        isRemoteAudioEnabled = call.isRemoteAudioEnabled
        isRemoteVideoEnabled = call.isRemoteVideoEnabled
        CallKitManager.shared.reportConnected(call)
    }

    func didStartReconnecting(_ call: DirectCall) {
        status = .reconnecting
    }

    func didReconnect(_ call: DirectCall) {
        status = .connected
    }

    func didRemoteAudioSettingsChange(_ call: DirectCall) {
        isRemoteAudioEnabled = call.isRemoteAudioEnabled
    }

    func didRemoteVideoSettingsChange(_ call: DirectCall) {
        isRemoteVideoEnabled = call.isRemoteVideoEnabled
    }

    func didAudioDeviceChange(_ call: DirectCall,
                              session: AVAudioSession,
                              previousRoute: AVAudioSessionRouteDescription,
                              reason: AVAudioSession.RouteChangeReason) {
        guard !call.isEnded, let output = session.currentRoute.outputs.first else { return }
        audioOutputImageName = CallText.audioOutputImageName(for: output.portType)
    }

    func didEnd(_ call: DirectCall) {
        status = .ended(call.endResult)

        if let callLog = call.callLog {
            CallHistoryStore.shared.insert(CallHistory(callLog: callLog))
        }

        // When the other user ended the call, end it in CallKit as well.
        if let enderId = call.endedBy?.userId, enderId != SendBirdCall.currentUser?.userId {
            CallKitManager.shared.endCall(call)
        }

        // Show the result for a second, then close the call screen.
        let callId = call.callId
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            CallRouter.shared.dismiss(callId: callId)
        }
    }
}
