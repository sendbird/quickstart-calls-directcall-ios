//
//  DialView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SendBirdCalls
import SwiftUI

/// Makes a voice or video call to the entered user ID.
struct DialView: View {
    @State private var calleeId = ""
    @State private var isDialing = false
    @State private var errorMessage: String?

    private var credential: Credential? { AuthService.shared.currentCredential }
    private var trimmedCalleeId: String { calleeId.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var canDial: Bool { !trimmedCalleeId.isEmpty && !isDialing }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                signedInUser

                VStack(alignment: .leading, spacing: 12) {
                    Text("Make a call")
                        .font(.headline)
                    TextField("Enter user ID", text: $calleeId)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(.white, in: RoundedRectangle(cornerRadius: 8))
                    HStack(spacing: 16) {
                        Button {
                            dial(isVideoCall: false)
                        } label: {
                            Image(canDial ? "btnCallVoice" : "btnCallVoiceDisabled")
                        }
                        Button {
                            dial(isVideoCall: true)
                        } label: {
                            Image(canDial ? "btnCallVideo" : "btnCallVideoDisabled")
                        }
                        if isDialing {
                            ProgressView()
                        }
                    }
                    .disabled(!canDial)
                }
                Spacer()
            }
            .padding(16)
            .background(Color(white: 0.94))
            .navigationTitle("Dial")
            .alert("Couldn’t make a call",
                   isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var signedInUser: some View {
        HStack(spacing: 12) {
            ProfileImage(url: credential?.profileURL)
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text(credential?.nickname?.isEmpty == false ? credential?.nickname ?? "" : "—")
                    .font(.headline)
                Text("User ID: \(credential?.userId ?? "")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(.white, in: RoundedRectangle(cornerRadius: 12))
    }

    private func dial(isVideoCall: Bool) {
        let callOptions = CallOptions(isAudioEnabled: true, isVideoEnabled: isVideoCall, useFrontCamera: true)
        let params = DialParams(calleeId: trimmedCalleeId, isVideoCall: isVideoCall, callOptions: callOptions, customItems: [:])

        isDialing = true
        SendBirdCall.dial(with: params) { call, error in
            isDialing = false
            guard let call, error == nil else {
                errorMessage = error?.localizedDescription ?? "Something went wrong. Try again."
                return
            }
            CallRouter.shared.present(call, isDialing: true)
        }
    }
}
