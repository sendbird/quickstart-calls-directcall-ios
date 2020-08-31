//
//  SignInWithQRViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/17.
//  Copyright © 2020 SendBird Inc. All rights reserved.
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
        didSet {
            let sampleVersion = Bundle.main.version
            self.versionLabel.text = "QuickStart \(sampleVersion)  Calls SDK \(SendBirdCall.sdkVersion)"
        }
    }
    
    let indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // After setting a delegate, delegate.didSignIn will be called.
        SendBirdCredentialManager.shared.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "scanQR":
            guard let qrCodeVC = segue.destination.children.first as? QRCodeViewController else { return }
            if #available(iOS 13.0, *) { qrCodeVC.isModalInPresentation = true }
        case "manual":
            guard let signInVC = segue.destination.children.first as? SignInManuallyViewController else { return }
            signInVC.delegate = self
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

// MARK: - QR Code
extension SignInWithQRViewController: SignInDelegate {
    @IBAction func didTapScanQRCode() {
        performSegue(withIdentifier: "scanQR", sender: nil)
    }
    
    @IBAction func didTapSignInManually() {
        performSegue(withIdentifier: "manual", sender: nil)
    }
    
    // Delegate method
    func didSignIn(credential: SendBirdCredentialManager.SendBirdCredential) {
        // Store credential
        UserDefaults.standard.credential = credential
        self.updateButtonUI()
        self.signIn()
    }
}

// MARK: SendBirdCalls
extension SignInWithQRViewController {
    func signIn() {
        // Execute only when the app ID is valid.
        guard let credential = UserDefaults.standard.credential else { return }
        let voipPushToken = UserDefaults.standard.voipPushToken
        let authParams = AuthenticateParams(userId: credential.userID,
                                            accessToken: credential.accessToken)
        
        self.indicator.startLoading(on: self.view)
        
        // Update app ID
        SendBirdCall.configure(appId: credential.appID)

        SendBirdCall.authenticate(with: authParams) { user, error in
            guard let user = user, error == nil else {
                // Handling error
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.indicator.stopLoading()
                    self.resetButtonUI()
                    let errorDescription = String(error?.localizedDescription ?? "")
                    self.presentErrorAlert(message: "\(errorDescription)")
                }
                // If there is something wrong, clear all stored information except for voip push token.
                UserDefaults.standard.clear()
                return
            }
            
            // Store the details for the user for its ID as a key.
            UserDefaults.standard.userDetail = (user.nickname, user.profileURL)
            
            // register push token
            SendBirdCall.registerVoIPPush(token: voipPushToken, unique: false) { error in
                if let error = error { print(error) }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.indicator.stopLoading()
                    self.resetButtonUI()
                    self.performSegue(withIdentifier: "signInWithQRCode", sender: nil)
                }
            }
            
        }
    }
}
