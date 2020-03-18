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

protocol QRCodeScanDelegate: class {
    func didScanQRCode(appId: String, userId: String, accessToken: String?)
}

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    typealias SendBirdQRInfo = [String: String?]
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            guard let layer = self.previewLayer else { return }
            layer.frame = view.layer.bounds
            layer.videoGravity = .resizeAspectFill
            view.layer.insertSublayer(layer, at: 0)
        }
    }
    
    weak var delegate: QRCodeScanDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.captureSession = AVCaptureSession()

        guard let captureSession = self.captureSession else { return }
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let metadataOutput = AVCaptureMetadataOutput()
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        // Add Input
        guard captureSession.canAddInput(videoInput) == true else {
            self.alertError(message: "Your device does not support scanning a code from an item. Please use a device with a camera")
            self.captureSession = nil
            return
        }
        captureSession.addInput(videoInput)

        // Add Output
        guard captureSession.canAddOutput(metadataOutput) == true else {
            self.alertError(message: "Your device does not support scanning a code from an item. Please use a device with a camera")
            self.captureSession = nil
            return
        }
        captureSession.addOutput(metadataOutput)
        
        // MetaData Output
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        // Preview Set
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        captureSession.startRunning()
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

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        self.captureSession?.stopRunning()

        guard let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            self.alertError(message: "Not available QR Code for SendBirdCalls") { _ in
                self.captureSession?.startRunning()
            }
            return
        }
        guard let stringValue = readableObject.stringValue else {
            self.alertError(message: "Not available QR Code for SendBirdCalls") { _ in
                self.captureSession?.startRunning()
            }
            return
        }
        guard let data = Data(base64Encoded: stringValue) else {
            self.alertError(message: "Not available QR Code for SendBirdCalls") { _ in
                self.captureSession?.startRunning()
            }
            return
        }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.decodeBase64EncodedQRCode(data)
    }
    
    private func decodeBase64EncodedQRCode(_ code: Data) {
        do {
            let decodedDict = try JSONDecoder().decode(SendBirdQRInfo.self, from: code)
            self.dispatchQRInfo(decodedDict)
            self.dismiss(animated: true, completion: nil)
        } catch {
            self.alertError(message: error.localizedDescription) { _ in
                self.captureSession?.startRunning()
            }
            print(error.localizedDescription)
        }
    }
    
    private func dispatchQRInfo(_ qrInfo: SendBirdQRInfo) {
        guard let appId = qrInfo["app_id"] as? String else { return }
        guard let userId = qrInfo["user_id"] as? String else { return }
        let accessToken = qrInfo["access_token"] as? String
        self.delegate?.didScanQRCode(appId: appId, userId: userId, accessToken: accessToken)
    }
}
