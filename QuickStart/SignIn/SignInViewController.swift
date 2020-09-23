//
//  SignInViewController.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

class SignInViewController: UIViewController, UITextFieldDelegate {
    // Logo
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    
    // ID
    @IBOutlet weak var userIdTextField: UITextField!
    
    // SignIn
    @IBOutlet weak var signInButton: UIButton!
    
    // Footnote
    @IBOutlet weak var versionLabel: UILabel! {
        didSet { self.versionLabel.text = versionInfo }
    }
    
    var indicator = UIActivityIndicatorView()
    var userId: String?
    var deviceToken: Data?
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userIdTextField.delegate = self
        
        NotificationCenter.observeKeyboard(showAction: #selector(keyboardWillShow(_:)),
                                           hideAction: #selector(keyboardWillHide(_:)),
                                           target: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - User Interaction with SendBirdCall
extension SignInViewController {
    @IBAction func didTapSignIn() {
        guard let userId = self.userIdTextField.text?.collapsed else {
            self.presentErrorAlert(message: CredentialErrors.noUserID.localizedDescription)
            return
        }
        self.updateButtonUI()
        self.indicator.startLoading(on: self.view)
        self.signIn(with: userId)
    }
    
    func signIn(with userID: String) {
        let authParams = AuthenticateParams(userId: userID, accessToken: nil)
        
        SendBirdCall.authenticate(with: authParams) { (user, error) in
            
            guard user != nil else {
                // Failed
                DispatchQueue.main.async { [self] in
                    self.indicator.stopAnimating()
                    self.resetButtonUI()
                    let error: Error = error ?? CredentialErrors.unknown
                    self.presentErrorAlert(message: error.localizedDescription)
                }
                
                // (Optional) If there is something wrong, clear all stored information except for voip push token.
                UserDefaults.standard.clear()
                return
            }
            
            // create credential object with updated information
            let credential = Credential(accessToken: nil)
            let credentialManager = CredentialManager.shared
            credentialManager.updateCredential(credential)
            
            // register push token
            SendBirdCall.registerVoIPPush(token: UserDefaults.standard.voipPushToken, unique: false) { error in
                if let error = error { print(error) }
                
                DispatchQueue.main.async { [self] in
                    self.indicator.stopLoading()
                    self.resetButtonUI()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

// MARK: UI
extension SignInViewController {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func resetButtonUI() {
        self.signInButton.backgroundColor = UIColor.QuickStart.purple.color
        self.signInButton.setTitleColor(UIColor.QuickStart.white.color, for: .normal)
        self.signInButton.setTitle("Sign In", for: .normal)
        self.signInButton.isEnabled = true
    }
    
    func updateButtonUI() {
        self.signInButton.backgroundColor = UIColor.QuickStart.lightGray.color
        self.signInButton.setTitleColor(UIColor.QuickStart.black.color, for: .normal)
        self.signInButton.setTitle("Signing In...", for: .normal)
        self.signInButton.isEnabled = false
    }
    
    @objc
    func keyboardWillShow(_ notification: Notification) {
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            self.userIdTextField.layer.borderWidth = 1.0
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    // MARK: When Keyboard Hide
    @objc
    func keyboardWillHide(_ notification: Notification) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            self.userIdTextField.layer.borderWidth = 0.0
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}
