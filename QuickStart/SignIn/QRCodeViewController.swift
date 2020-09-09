//
//  QRCodeViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/17.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import AVFoundation
import SendBirdCalls

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var scanView: UIView!
    
    typealias SendBirdQRInfo = [String: String?]
    
    var captureSession: AVCaptureSession? {
        didSet {
            guard let captureSession = self.captureSession else { return }
            self.updateCaptureSession(captureSession)
        }
    }
    var previewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            guard let layer = self.previewLayer else { return }
            layer.frame = self.scanView.layer.bounds
            layer.videoGravity = .resizeAspectFill
            self.scanView.layer.insertSublayer(layer, at: 0)
            
            self.captureSession?.startRunning()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.captureSession = AVCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard self.captureSession?.isRunning == false else { return }
        self.captureSession?.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard self.captureSession?.isRunning == true else { return }
        self.captureSession?.stopRunning()
    }
    
    @IBAction func didTapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func updateCaptureSession(_ captureSession: AVCaptureSession) {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let metadataOutput = AVCaptureMetadataOutput()
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        // Add Input / Output
        guard captureSession.canAddInput(videoInput) == true,
            captureSession.canAddOutput(metadataOutput) == true else {
                self.presentErrorAlert(message: "Your device does not support scanning a code from an item. Please use a device with a camera")
                self.captureSession = nil
                return
        }
        captureSession.addInput(videoInput)
        captureSession.addOutput(metadataOutput)
        
        // MetaData Output
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        self.captureSession?.stopRunning()
        
        let invalidQRcode = "Mobile sign-in is not enabled.  Please first enable notifications on the SendBird Dashboard."
        let appStoreLink = "This QR code is a link to download the mobile quickstart app, which is already installed on your device. To sign into this app, please generate and scan a user-specific QR code in Calls studio."
        
        guard let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue else {
                // Invalid QR code
                self.presentErrorAlert(message: invalidQRcode) { [weak self] _ in
                    guard let self = self else { return }
                    self.captureSession?.startRunning()
                }
                return
        }
        
        guard stringValue != "https://dashboard.sendbird.com/calls/mobile" else {
            // AppStore link
            self.presentErrorAlert(message: appStoreLink) { [weak self] _ in
                guard let self = self else { return }
                self.captureSession?.startRunning()
            }
            return
        }
        
        guard let data = Data(base64Encoded: stringValue) else {
            // Invalid QR code
            self.presentErrorAlert(message: invalidQRcode) { [weak self] _ in
                guard let self = self else { return }
                self.captureSession?.startRunning()
            }
            return
        }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        SendBirdCredentialManager.shared.handle(qrData: data, onSucceed: {
            self.dismiss(animated: true, completion: nil) // Succeed
        }) { (error) in
            self.presentErrorAlert(message: error.localizedDescription) { _ in // Failed
                self.captureSession?.startRunning()
            }
        }
    }
}
