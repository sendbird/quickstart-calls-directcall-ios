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
    
    var activityIndicator = UIActivityIndicatorView()
    var userId: String?
    var deviceToken: Data?
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userIdTextField.delegate = self
        
        NotificationCenter.observeKeyboard(action1: #selector(keyboardWillShow(_:)), action2: #selector(keyboardWillHide(_:)), on: self)
        
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
        guard let userId = self.userIdTextField.filteredText, !userId.isEmpty else {
            self.presentErrorAlert(message: "Please enter your ID and your name")
            return
        }
        self.updateButtonUI()
        self.signIn(userId: userId)
    }
    
    func signIn(userId: String) {
        // MARK: SendBirdCall.authenticate()
        let params = AuthenticateParams(userId: userId, accessToken: nil, voipPushToken: UserDefaults.standard.voipPushToken, unique: false)
        self.startLoading()
        
        SendBirdCall.authenticate(with: params) { user, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.stopLoading()
                self.resetButtonUI()
            }
            guard let user = user, error == nil else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let errorDescription = String(error?.localizedDescription ?? "")
                    self.presentErrorAlert(message: "Failed to authenticate\n\(errorDescription)")
                }
                return
            }
            UserDefaults.standard.autoLogin = true
            UserDefaults.standard.user = (user.userId, user.nickname, user.profileURL)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.performSegue(withIdentifier: "signIn", sender: nil)
            }
        }
    }
}
    

// MARK: UI
extension SignInViewController {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func startLoading() {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = .gray
        self.view.addSubview(activityIndicator)
        
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopLoading() {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func resetButtonUI() {
        self.signInButton.backgroundColor = UIColor(red: 123 / 255, green: 83 / 255, blue: 239 / 255, alpha: 1.0)
        self.signInButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.88), for: .normal)
        self.signInButton.setTitle("Sign In", for: .normal)
        self.signInButton.isEnabled = true
    }
    
    func updateButtonUI() {
        self.signInButton.backgroundColor = UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1.0)
        self.signInButton.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.12), for: .normal)
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
