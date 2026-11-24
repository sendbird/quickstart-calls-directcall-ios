//
//  CallHistoryView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SwiftUI

/// The list of past calls. Tap a call to call the same user again.
struct CallHistoryView: View {
    private var store: CallHistoryStore { .shared }
    @State private var isDialing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if store.items.isEmpty {
                    emptyState
                } else {
                    List(store.items) { history in
                        row(history)
                            .listRowInsets(EdgeInsets())
                    }
                    .listStyle(.plain)
                }
            }
            .background(.white)
            .navigationTitle("Recents")
            .navigationBarTitleDisplayMode(.inline)
            .disabled(isDialing)
            .overlay {
                if isDialing { ProgressView() }
            }
            .task { store.loadFromServerIfEmpty() }
            .errorAlert($errorMessage)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 28) {
            Image("iconCallHistory")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            Text("The list of calls you make will show here.\nTap the phone button to start making a call.")
                .font(.system(size: 14))
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func row(_ history: CallHistory) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Image(history.callTypeImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            ProfileImage(url: history.remoteProfileURL)
                .frame(width: 56, height: 56)
                .padding(.leading, 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(history.remoteNickname)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(2)
                Text("User ID: \(history.remoteUserId)")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.secondaryText)
                Text(history.resultText)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.secondaryText)
            }
            .padding(.leading, 16)
            Spacer(minLength: 4)
            VStack(alignment: .trailing, spacing: 10) {
                Text(history.startedAtText)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
                HStack(spacing: 12) {
                    Button {
                        dial(history, isVideoCall: false)
                    } label: {
                        Image("btnCallVoiceTertiary")
                            .resizable()
                            .frame(width: 32, height: 32)
                    }
                    Button {
                        dial(history, isVideoCall: true)
                    } label: {
                        Image("btnCallVideoTertiary")
                            .resizable()
                            .frame(width: 32, height: 32)
                    }
                }
                // Keep the buttons from triggering the row's tap action.
                .buttonStyle(.borderless)
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            // Tapping a row calls again with the same type of call.
            dial(history, isVideoCall: history.hasVideo)
        }
    }

    private func dial(_ history: CallHistory, isVideoCall: Bool) {
        // The user is unknown when the call log has no information about the other user.
        guard history.remoteUserId != "Unknown" else { return }
        isDialing = true
        Task {
            defer { isDialing = false }
            do {
                try await Dialer.dial(calleeId: history.remoteUserId, isVideoCall: isVideoCall)
            } catch {
                let prefix = isVideoCall ? "Couldn't make video call." : "Couldn't make call."
                errorMessage = "\(prefix)\n\(error.localizedDescription)"
            }
        }
    }
}
