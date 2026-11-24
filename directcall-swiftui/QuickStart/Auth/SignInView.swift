//
//  SignInView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SwiftUI

/// Signs in by scanning a QR code from Calls studio, or by entering the information by hand.
struct SignInView: View {
    @State private var isScanning = false
    @State private var isEnteringManually = false
    @State private var isSigningIn = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            Image("icLogoSymbol")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .padding(.top, 96)
            Text("Sendbird Calls")
                .font(.system(size: 24, weight: .semibold))
                .padding(.top, 24)

            Button("Sign in with QR code") { isScanning = true }
                .buttonStyle(FilledButtonStyle())
                .padding(.top, 40)
            divider
                .padding(.vertical, 20)
            Button("Sign in with ID") { isEnteringManually = true }
                .buttonStyle(OutlinedButtonStyle())

            Spacer()
            Text(AppInfo.versionDescription)
                .font(.footnote)
                .foregroundStyle(Theme.tertiaryText)
                .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
        .background(.white)
        .disabled(isSigningIn)
        .overlay {
            if isSigningIn { ProgressView() }
        }
        .sheet(isPresented: $isScanning) {
            QRScanView { value in
                isScanning = false
                signIn { try await AuthService.shared.signIn(qrString: value) }
            }
        }
        .sheet(isPresented: $isEnteringManually) {
            ManualSignInView { credential in
                signIn { try await AuthService.shared.signIn(credential) }
            }
        }
        .errorAlert($errorMessage)
    }

    /// A line with "Or" in the middle.
    private var divider: some View {
        ZStack {
            Rectangle()
                .fill(Theme.divider)
                .frame(height: 1)
            Text("Or")
                .font(.system(size: 17))
                .foregroundStyle(Theme.tertiaryText)
                .frame(width: 44)
                .background(.white)
        }
    }

    private func signIn(_ operation: @escaping () async throws -> Void) {
        isSigningIn = true
        Task {
            defer { isSigningIn = false }
            do {
                try await operation()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
