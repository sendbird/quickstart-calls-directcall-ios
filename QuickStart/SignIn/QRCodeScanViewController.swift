//
//  QRCodeScanViewController.swift
//  QuickStart
//
//  Created by Minhyuk Kim on 2020/01/09.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import AVFoundation
import SendBirdCalls

class QRCodeScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
            let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddInput(videoInput) && captureSession.canAddOutput(metadataOutput)) {
            captureSession.addInput(videoInput)
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.insertSublayer(previewLayer, below: view.layer.sublayers?.first)
        
        captureSession.startRunning()
        
        self.captureSession = captureSession
        self.previewLayer = previewLayer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.captureSession?.isRunning == false {
            self.captureSession?.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.captureSession?.isRunning == true {
            self.captureSession?.stopRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.captureSession = nil
        
        super.viewDidDisappear(animated)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        self.captureSession?.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let appId = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            let alert = UIAlertController(title: "Code Found", message: "App ID: \(appId)", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { _ in
                SendBirdCall.configure(appId: appId)
                
                self.dismiss(animated: true)
            })
            alert.addAction(confirmAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                self.captureSession?.startRunning()
            })
            alert.addAction(cancelAction)
            
            present(alert, animated: true)
        }
    }
    
    func failed() {
        self.captureSession = nil
        
        let alert = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true)
    }
}
