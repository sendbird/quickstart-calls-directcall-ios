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
    
    var captureSession: AVCaptureSession? {
        didSet {
            guard let captureSession = self.captureSession else { return }
            self.updateCaptureSession(captureSession)
        }
    }
    var previewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            guard let layer = self.previewLayer else { return }
            layer.frame = view.layer.bounds
            layer.videoGravity = .resizeAspectFill
            view.layer.insertSublayer(layer, at: 0)
            
            self.captureSession?.startRunning()
        }
    }
    
    weak var delegate: QRCodeScanDelegate?
    
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

        guard let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue,
            let data = Data(base64Encoded: stringValue) else {
            self.presentErrorAlert(message: "Not available QR Code for SendBirdCalls") { _ in
                self.captureSession?.startRunning()
            }
            return
        }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.decodeBase64EncodedQRCode(data)
    }
    
    // MARK: Decode QR Code
    private func decodeBase64EncodedQRCode(_ code: Data) {
        do {
            let decodedDict = try JSONDecoder().decode(SendBirdQRInfo.self, from: code)
            self.dispatchQRInfo(decodedDict)
            self.dismiss(animated: true, completion: nil)
        } catch {
            self.presentErrorAlert(message: error.localizedDescription) { _ in
                self.captureSession?.startRunning()
            }
            print(error.localizedDescription)
        }
    }
    
    // MARK: QRCodeScanDelegate
    private func dispatchQRInfo(_ qrInfo: SendBirdQRInfo) {
        guard let appId = qrInfo["app_id"] as? String else { return }
        guard let userId = qrInfo["user_id"] as? String else { return }
        let accessToken = qrInfo["access_token"] as? String
        self.delegate?.didScanQRCode(appId: appId, userId: userId, accessToken: accessToken)
    }
}
