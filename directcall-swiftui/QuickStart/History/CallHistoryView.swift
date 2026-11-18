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
                    ContentUnavailableView {
                        Label("No calls yet", image: "iconCallHistory")
                    } description: {
                        Text("The list of calls you make will show here. Tap the phone button to start making a call.")
                    }
                } else {
                    List(store.items) { history in
                        row(history)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Recents")
            .disabled(isDialing)
            .task { store.loadFromServerIfEmpty() }
            .alert("Couldn’t make a call",
                   isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func row(_ history: CallHistory) -> some View {
        HStack(spacing: 12) {
            Image(history.callTypeImageName)
            ProfileImage(url: history.remoteProfileURL)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(history.remoteNickname)
                    .font(.headline)
                    .lineLimit(1)
                Text("User ID: \(history.remoteUserId)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(history.resultText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Text(history.startedAtText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Button {
                        dial(history, isVideoCall: false)
                    } label: {
                        Image("btnCallVoiceTertiary")
                    }
                    Button {
                        dial(history, isVideoCall: true)
                    } label: {
                        Image("btnCallVideoTertiary")
                    }
                }
                // Keep the buttons from triggering the row's tap action.
                .buttonStyle(.borderless)
            }
        }
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
                errorMessage = error.localizedDescription
            }
        }
    }
}
