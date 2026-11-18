//
//  CallKitManager.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import AVFoundation
import CallKit
import SendBirdCalls
import UIKit

/// Connects Sendbird Calls to CallKit.
///
/// CallKit shows the system call screen (including on the lock screen), keeps calls running in the background,
/// and adds calls to the Phone app's Recents.
final class CallKitManager: NSObject, CXProviderDelegate {
    static let shared = CallKitManager()

    private let provider: CXProvider
    private let controller = CXCallController()

    private override init() {
        provider = CXProvider(configuration: Self.configuration)
        super.init()
        provider.setDelegate(self, queue: .main)
    }

    private static var configuration: CXProviderConfiguration {
        let configuration = CXProviderConfiguration()
        if let image = UIImage(named: "icLogoSymbolInverse") {
            configuration.iconTemplateImageData = image.pngData()
        }
        // Sendbird Calls supports video calls either way, but this must be `true` to start video calls from Recents
        // and to show the correct call type there.
        configuration.supportsVideo = true
        configuration.maximumCallsPerCallGroup = 1
        configuration.maximumCallGroups = 1
        configuration.supportedHandleTypes = [.generic]
        // For dialing and reconnecting sounds, see `SoundEffects`.
        configuration.ringtoneSound = "Ringing.mp3"
        return configuration
    }

    var currentCalls: [CXCall] { controller.callObserver.calls }

    /// Returns `false` when CallKit already knows the call, so that the same call is not reported twice.
    func shouldProcessCall(uuid: UUID) -> Bool {
        !currentCalls.contains { $0.uuid == uuid }
    }

    // MARK: - Reporting to CallKit

    func reportIncomingCall(uuid: UUID, update: CXCallUpdate, completion: ((Error?) -> Void)? = nil) {
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            completion?(error)
        }
    }

    func reportConnected(_ call: DirectCall) {
        guard let uuid = call.callUUID else { return }
        provider.reportOutgoingCall(with: uuid, connectedAt: Date(timeIntervalSince1970: Double(call.startedAt) / 1000))
    }

    func reportEnded(uuid: UUID, reason: DirectCallEndResult) {
        guard let reason = reason.cxEndedReason else { return }
        provider.reportCall(with: uuid, endedAt: Date(), reason: reason)
    }

    // MARK: - Requesting CallKit actions

    /// Tells CallKit about an outgoing call so that it shows in Recents and keeps running in the background.
    func startCall(_ call: DirectCall) {
        guard let uuid = call.callUUID, let calleeId = call.callee?.userId else { return }
        let action = CXStartCallAction(call: uuid, handle: CXHandle(type: .generic, value: calleeId))
        action.isVideo = call.isVideoCall
        request(action)
    }

    func endCall(_ call: DirectCall) {
        guard let uuid = call.callUUID else { return }
        request(CXEndCallAction(call: uuid))
    }

    private func request(_ action: CXAction) {
        controller.request(CXTransaction(action: action)) { error in
            if let error {
                print("[QuickStart] CallKit transaction failed: \(error)")
            }
        }
    }

    // MARK: - CXProviderDelegate

    func providerDidReset(_ provider: CXProvider) { }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        if call.myRole == .caller {
            provider.reportOutgoingCall(with: action.callUUID,
                                        startedConnectingAt: Date(timeIntervalSince1970: Double(call.startedAt) / 1000))
        }
        action.fulfill()
    }

    /// The user answered on the CallKit screen.
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        Task { @MainActor in
            do {
                // The app may have been launched by the VoIP push and not be signed in yet.
                try await AuthService.shared.authenticateIfNeeded()
            } catch {
                action.fail()
                return
            }
            let callOptions = CallOptions(isAudioEnabled: true, isVideoEnabled: call.isVideoCall, useFrontCamera: true)
            call.accept(with: AcceptParams(callOptions: callOptions))
            CallRouter.shared.present(call, isDialing: false)
            action.fulfill()
        }
    }

    /// The user declined or ended the call on the CallKit screen, or the app requested `CXEndCallAction`.
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        // The call has already ended, for example because the other user hung up.
        guard call.endResult == .none || call.endResult == .unknown else {
            action.fulfill()
            return
        }
        Task { @MainActor in
            // Keep running in the background until the end request reaches the server.
            let backgroundTask = UIApplication.shared.beginBackgroundTask()
            defer { UIApplication.shared.endBackgroundTask(backgroundTask) }
            do {
                try await AuthService.shared.authenticateIfNeeded()
            } catch {
                action.fail()
                return
            }
            await withCheckedContinuation { continuation in
                call.end { continuation.resume() }
            }
            action.fulfill()
        }
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        action.isMuted ? call.muteMicrophone() : call.unmuteMicrophone()
        action.fulfill()
    }

    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) { }

    // CallKit activates the audio session for calls. Sendbird Calls needs to know when it happens.
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        SendBirdCall.audioSessionDidActivate(audioSession)
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        SendBirdCall.audioSessionDidDeactivate(audioSession)
    }
}

extension DirectCallEndResult {
    /// The reason to report to CallKit. `nil` when the call has not ended.
    var cxEndedReason: CXCallEndedReason? {
        switch self {
        case .connectionLost, .timedOut, .acceptFailed, .dialFailed, .unknown, .notConnected:
            return .failed
        case .completed, .canceled:
            return .remoteEnded
        case .declined:
            return .declinedElsewhere
        case .noAnswer:
            return .unanswered
        case .otherDeviceAccepted:
            return .answeredElsewhere
        case .none:
            return nil
        @unknown default:
            return .failed
        }
    }
}
