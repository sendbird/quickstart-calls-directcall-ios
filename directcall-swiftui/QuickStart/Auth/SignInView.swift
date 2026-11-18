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
        VStack(spacing: 16) {
            Spacer()
            Image("icLogoSymbol")
            Text("Sendbird Calls")
                .font(.title2.bold())
            // The guide image is drawn in white, so it sits on a dark background.
            Image("imgGuideQrcode")
                .padding(24)
                .background(.black, in: RoundedRectangle(cornerRadius: 16))
                .padding(.top, 24)
            Text("Scan QR code from Calls studio on Sendbird dashboard.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Button {
                isScanning = true
            } label: {
                Text("Sign in with QR code")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Button("Sign in manually") {
                isEnteringManually = true
            }
            Text(AppInfo.versionDescription)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .padding(24)
        .disabled(isSigningIn)
        .overlay {
            if isSigningIn { ProgressView() }
        }
        .fullScreenCover(isPresented: $isScanning) {
            scanner
        }
        .sheet(isPresented: $isEnteringManually) {
            ManualSignInView { credential in
                signIn { try await AuthService.shared.signIn(credential) }
            }
        }
        .alert("Couldn’t sign in", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var scanner: some View {
        ZStack(alignment: .topLeading) {
            if QRScannerView.isCameraAvailable {
                QRScannerView { value in
                    isScanning = false
                    signIn { try await AuthService.shared.signIn(qrString: value) }
                }
                .ignoresSafeArea()
            } else {
                Text("The camera is not available on this device.")
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black)
            }
            Button("Cancel") { isScanning = false }
                .foregroundStyle(.white)
                .padding()
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
