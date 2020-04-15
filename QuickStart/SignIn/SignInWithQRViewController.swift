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
        
        if UserDefaults.standard.autoLogin == true {
            self.updateButtonUI()
            self.signIn()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "scanQR":
            guard let qrCodeVC = segue.destination.children.first as? QRCodeViewController else { return }
            qrCodeVC.delegate = self
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
        self.scanButton.backgroundColor = #colorLiteral(red: 0.509719789, green: 0.3168306947, blue: 0.9718012214, alpha: 1)
        self.scanButton.setTitle("Sign in with QR code", for: .normal)
        self.scanButton.isEnabled = true
    }
    
    func updateButtonUI() {
        self.view.subviews.filter({ $0.tag == 1 }).forEach { $0.isHidden = true }   // Hide lines and "Or" label
        self.signInManuallyButton.isHidden = true
        
        self.scanButton.backgroundColor = UIColor.QuickStart.lightGray.color
        self.scanButton.setTitleColor(UIColor.black.withAlphaComponent(0.12), for: .normal)
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
    func didSignIn(appId: String, userId: String, accessToken: String?) {
        SendBirdCall.configure(appId: appId)
        // You must call `SendBirdCall.addDelegate(_:identifier:)` right after configuring new app ID
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            SendBirdCall.addDelegate(appDelegate, identifier: "com.sendbird.calls.quickstart.delegate")
        }

        UserDefaults.standard.appId = appId
        UserDefaults.standard.user.id = userId
        UserDefaults.standard.accessToken = accessToken
        self.updateButtonUI()
        self.signIn()
    }
}

// MARK: SendBirdCalls
extension SignInWithQRViewController {
    func signIn() {
        let userId = UserDefaults.standard.user.id
        let accessToken = UserDefaults.standard.accessToken
        let voipPushToken = UserDefaults.standard.voipPushToken
        let authParams = AuthenticateParams(userId: userId, accessToken: accessToken, voipPushToken: voipPushToken, unique: false)
        self.indicator.startLoading(on: self.view)
        
        SendBirdCall.authenticate(with: authParams) { user, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.indicator.stopLoading()
                self.resetButtonUI()
            }
            
            guard let user = user, error == nil else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let errorDescription = String(error?.localizedDescription ?? "")
                    self.presentErrorAlert(message: "\(errorDescription)")
                }
                UserDefaults.standard.clear()
                return
            }
            UserDefaults.standard.autoLogin = true
            UserDefaults.standard.user = (user.userId, user.nickname, user.profileURL)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.performSegue(withIdentifier: "signInWithQRCode", sender: nil)
            }
        }
    }
}
