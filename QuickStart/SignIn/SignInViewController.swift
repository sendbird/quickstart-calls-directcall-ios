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
        didSet {
            let sampleVersion = Bundle.main.version
            self.versionLabel.text = "QuickStart \(sampleVersion)  Calls SDK \(SendBirdCall.sdkVersion)"
        }
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
        
        if UserDefaults.standard.autoLogin == true {
            self.updateButtonUI()
            self.signIn(userId: UserDefaults.standard.user.id)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


// MARK: - User Interaction with SendBirdCall
extension SignInViewController {
    @IBAction func didTapSignIn() {
        guard let userId = self.userIdTextField.text?.collapsed else {
            self.presentErrorAlert(message: "Please enter your ID and your name")
            return
        }
        self.updateButtonUI()
        self.signIn(userId: userId)
    }
    
    func signIn(userId: String) {
        // MARK: SendBirdCall.authenticate()

        let authParams = AuthenticateParams(userId: userId, accessToken: nil)
        self.indicator.startLoading(on: self.view)

        
        SendBirdCall.authenticate(with: authParams) { user, error in
            guard let user = user, error == nil else {
                // Handling error
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.indicator.stopLoading()
                    self.resetButtonUI()
                    let errorDescription = String(error?.localizedDescription ?? "")
                    self.presentErrorAlert(message: "Failed to authenticate\n\(errorDescription)")
                }
                return
            }
            
            // Save data
            UserDefaults.standard.autoLogin = true
            UserDefaults.standard.user = (user.userId, user.nickname, user.profileURL)
            
            // register push token
            SendBirdCall.registerRemotePush(token: UserDefaults.standard.remotePushToken, unique: false) { error in
                if let error = error { print(error) }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.indicator.stopLoading()
                    self.resetButtonUI()
                    self.performSegue(withIdentifier: "signIn", sender: nil)
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
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            self.userIdTextField.layer.borderWidth = 1.0
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    
    // MARK: When Keyboard Hide
    @objc func keyboardWillHide(_ notification: Notification) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            self.userIdTextField.layer.borderWidth = 0.0
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}
