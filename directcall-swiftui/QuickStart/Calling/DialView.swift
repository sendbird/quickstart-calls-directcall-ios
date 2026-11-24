//
//  DialView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SwiftUI

/// Makes a voice or video call to the entered user ID.
struct DialView: View {
    @State private var calleeId = ""
    @State private var isDialing = false
    @State private var errorMessage: String?

    private var credential: Credential? { AuthService.shared.currentCredential }

    var body: some View {
        VStack(spacing: 0) {
            signedInUser
            Rectangle()
                .fill(Theme.divider)
                .frame(height: 1)

            Spacer()
            VStack(spacing: 0) {
                Text("Make a call")
                    .font(.system(size: 24, weight: .semibold))
                InputField(placeholder: "Enter user ID", text: $calleeId)
                    .padding(.top, 32)
                HStack(spacing: 32) {
                    Button {
                        dial(isVideoCall: true)
                    } label: {
                        Image("btnCallVideo")
                    }
                    Button {
                        dial(isVideoCall: false)
                    } label: {
                        Image("btnCallVoice")
                    }
                }
                .padding(.top, 40)
            }
            .padding(.horizontal, 24)
            Spacer()
            Spacer()
                .frame(height: 52)
        }
        .background(.white)
        .disabled(isDialing)
        .overlay {
            if isDialing { ProgressView() }
        }
        .errorAlert($errorMessage)
    }

    private var signedInUser: some View {
        HStack(spacing: 8) {
            ProfileImage(url: credential?.profileURL)
                .frame(width: 34, height: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(credential?.displayNickname ?? "-")
                    .font(.system(size: 16, weight: .bold))
                Text("User ID: \(credential?.userId ?? "-")")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 5)
        .padding(.bottom, 7)
    }

    private func dial(isVideoCall: Bool) {
        let calleeId = calleeId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !calleeId.isEmpty else {
            errorMessage = "User ID is required."
            return
        }
        isDialing = true
        Task {
            defer { isDialing = false }
            do {
                try await Dialer.dial(calleeId: calleeId, isVideoCall: isVideoCall)
            } catch {
                let prefix = isVideoCall ? "Couldn't make video call." : "Couldn't make call."
                errorMessage = "\(prefix)\n\(error.localizedDescription)"
            }
        }
    }
}
