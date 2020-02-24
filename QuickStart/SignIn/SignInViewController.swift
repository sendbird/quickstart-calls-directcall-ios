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
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userIdTextField: UITextField!
    
    // SignIn
    @IBOutlet weak var signInButton: UIButton!
    
    // Footnote
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    // Layout constraints
    @IBOutlet weak var constraintFromKeyboard: NSLayoutConstraint!
    
    var userId: String?
    var deviceToken: Data?
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userIdTextField.delegate = self
        
        NotificationCenter.observeKeyboard(action1: #selector(keyboardWillShow(_:)), action2: #selector(keyboardWillHide(_:)), on: self)
        
        self.setupUI()
        
        if UserDefaults.standard.autoLogin == true {
            self.signIn(userId: UserDefaults.standard.user.id)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


// MARK: - User Interaction with SendBirdCall
extension SignInViewController {
    @IBAction func didTapSignIn() {
        guard let userId = self.userIdTextField.filteredText, !userId.isEmpty else {
            self.alertError(message: "Please enter your ID and your name")
            return
        }
        
        self.signIn(userId: userId)
    }
    
    func signIn(userId: String) {
        // MARK: SendBirdCall.authenticate()
        let params = AuthenticateParams(userId: userId, accessToken: nil)
        
        SendBirdCall.authenticate(with: params) { user, error in
            guard let user = user, error == nil else {
                DispatchQueue.main.async {
                    self.alertError(message: "💣 \(String(describing: error))")
                }
                return
            }
            print("[ProfileURL] \(user.profileURL)")
            UserDefaults.standard.autoLogin = true
            UserDefaults.standard.user = (user.userId, user.nickname, user.profileURL)
            
            DispatchQueue.main.async {
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
    
    func setupUI() {
        self.logoImageView.image = UIImage(named: "logo_sendbird")
        self.mainLabel.text = "SendBirdCalls"
        
        self.userIdLabel.text = "ID"
        self.userIdTextField.placeholder = "Enter your ID"
        self.userIdTextField.textAlignment = .left
        
        self.signInButton.smoothAndWider()
        self.signInButton.setTitle("Sign In")
        
        let sampleVersion = Bundle.main.version
        self.versionLabel.text = sampleVersion + "SendBirdCalls v\(SendBirdCall.sdkVersion)"
        
        let current = Calendar.current
        let year = current.component(.year, from: Date())
        self.copyrightLabel.text = "© \(year) SendBird"
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrameBegin = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else  { return }
        let keyboardFrameBeginRect = keyboardFrameBegin.cgRectValue
        let keyboardHeight = keyboardFrameBeginRect.size.height
        
        let safeArea = keyboardHeight + 8.0
        let currentArea = self.view.frame.height - self.signInButton.frame.maxY
        let gap = safeArea - currentArea
            
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            if gap > 0 {
                self.constraintFromKeyboard.constant = self.constraintFromKeyboard.constant + gap
                self.logoImageView.alpha = 0.3
                self.mainLabel.alpha = 0.0
            }
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    
    // MARK: When Keyboard Hide
    @objc func keyboardWillHide(_ notification: Notification) {
        let value: CGFloat = 56.0
        
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            self.constraintFromKeyboard.constant = value
            self.logoImageView.alpha = 1.0
            self.mainLabel.alpha = 1.0
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}
