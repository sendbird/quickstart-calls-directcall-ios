//
//  QRScannerView.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import AVFoundation
import AudioToolbox
import SwiftUI
import UIKit

/// The "Scan QR code" screen: the camera with a guide frame, and a short instruction below it.
struct QRScanView: View {
    let onScan: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    Color.black
                    // The Simulator has no camera, so the area stays black there.
                    if QRScannerView.isCameraAvailable {
                        QRScannerView(onScan: onScan)
                    }
                    Image("imgGuideQrcode")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                }
                Text("Scan QR code from Calls studio on Sendbird dashboard.")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.tertiaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .frame(maxWidth: .infinity, minHeight: 88, alignment: .top)
                    .background(.white)
            }
            // The instruction area is 88 points tall, including the bottom safe area.
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Scan QR code")
            .navigationBarTitleDisplayMode(.inline)
            // The light gray bar of the UIKit sample's scan screen (#F5F6F4).
            .toolbarBackground(Color(red: 245 / 255, green: 246 / 255, blue: 244 / 255), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .tint(Theme.purple)
                }
            }
        }
    }
}

/// Scans a QR code with the back camera and returns its string value once.
struct QRScannerView: UIViewControllerRepresentable {
    let onScan: (String) -> Void

    static var isCameraAvailable: Bool { AVCaptureDevice.default(for: .video) != nil }

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let viewController = QRScannerViewController()
        viewController.onScan = onScan
        return viewController
    }

    func updateUIViewController(_ viewController: QRScannerViewController, context: Context) { }
}

final class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onScan: ((String) -> Void)?

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let session = self.session
        // `startRunning()` blocks the calling thread, so it runs off the main thread.
        DispatchQueue.global(qos: .userInitiated).async { session.startRunning() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.stopRunning()
    }

    private func configureSession() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(layer)
        previewLayer = layer
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let code = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = code.stringValue else { return }
        session.stopRunning()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        onScan?(value)
    }
}
