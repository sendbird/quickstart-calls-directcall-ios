//
//  SignInWithQRViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/17.
//  Copyright © 2020 Sendbird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

class SignInWithQRViewController: UIViewController {
    // Scan QR Code
    @IBOutlet weak var scanButton: UIButton!
    
    // Sign In Manually
    @IBOutlet weak var signInManuallyButton: UIButton!
    
    // Footnote
    @IBOutlet weak var versionLabel: UILabel! {
        didSet { self.versionLabel.text = versionInfo }
    }
    
    let indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "scanQR":
            guard let qrCodeVC = segue.destination.children.first as? QRCodeViewController else { return }
            if #available(iOS 13.0, *) { qrCodeVC.isModalInPresentation = true }
        case "manual":
            guard let signInVC = segue.destination.children.first as? SignInManuallyViewController else { return }
            if #available(iOS 13.0, *) { signInVC.isModalInPresentation = true }
        default: return
        }
    }
    
    func resetButtonUI() {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            self.view.subviews.filter({ $0.tag == 1 }).forEach { $0.isHidden = false }  // Show lines and "Or" label
            self.signInManuallyButton.isHidden = false
        }
        animator.startAnimation()
        
        self.scanButton.setTitleColor(UIColor.QuickStart.lightGray.color, for: .normal)
        self.scanButton.backgroundColor = UIColor.QuickStart.purple.color
        self.scanButton.setTitle("Sign in with QR code", for: .normal)
        self.scanButton.isEnabled = true
    }
    
    func updateButtonUI() {
        self.view.subviews.filter({ $0.tag == 1 }).forEach { $0.isHidden = true }   // Hide lines and "Or" label
        self.signInManuallyButton.isHidden = true
        
        self.scanButton.backgroundColor = UIColor.QuickStart.lightGray.color
        self.scanButton.setTitleColor(UIColor.QuickStart.black.color, for: .normal)
        self.scanButton.setTitle("Signing In...", for: .normal)
        self.scanButton.isEnabled = false
    }
}

// MARK: - Sign in options: QR code / ID
extension SignInWithQRViewController {
    @IBAction func didTapScanQRCode() {
        performSegue(withIdentifier: "scanQR", sender: nil)
    }
    
    @IBAction func didTapSignInManually() {
        performSegue(withIdentifier: "manual", sender: nil)
    }
}

// MARK: SendBirdCalls
extension SignInWithQRViewController {
    func signIn(with credential: Credential) {
        // Loading UI
        self.updateButtonUI()
        self.indicator.startLoading(on: self.view)
        
        // Execute only when the app ID is valid.
        let voipPushToken = UserDefaults.standard.voipPushToken
        
        // Update app ID
        SendBirdCall.configure(appId: credential.appId)
        
        let authParams = AuthenticateParams(userId: credential.userId, accessToken: credential.accessToken)
        SendBirdCall.authenticate(with: authParams) { (user, error) in
            guard user != nil else {
                DispatchQueue.main.async { [self] in
                    // Failed
                    self.indicator.stopLoading()
                    self.resetButtonUI()
                    let error: Error = error ?? CredentialErrors.unknown
                    self.presentErrorAlert(message: error.localizedDescription)
                }
                
                // (Optional) If there is something wrong, clear all stored information except for voip push token.
                UserDefaults.standard.clear()
                return
            }
            
            // create credential object with updated information
            let credential = Credential(accessToken: credential.accessToken)
            let credentialManager = CredentialManager.shared
            credentialManager.updateCredential(credential)
            
            // register push token
            SendBirdCall.registerVoIPPush(token: voipPushToken, unique: false) { error in
                if let error = error { print(error) }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.indicator.stopLoading()
                    self.resetButtonUI()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
