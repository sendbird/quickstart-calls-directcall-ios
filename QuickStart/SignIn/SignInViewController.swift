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
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    
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
                DispatchQueue.main.async { [weak self] in
                    self?.alertError(message: "💣 \(String(describing: error))")
                }
                return
            }
            UserDefaults.standard.autoLogin = true
            UserDefaults.standard.user = (user.userId, user.nickname, user.profileURL)
            
            DispatchQueue.main.async { [weak self] in
                self?.performSegue(withIdentifier: "signIn", sender: nil)
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
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.userIdTextField.frame.height))
        self.userIdTextField.leftView = paddingView
        self.userIdTextField.leftViewMode = UITextField.ViewMode.always
        
        let sampleVersion = Bundle.main.version
        self.versionLabel.text = "QuickStart \(sampleVersion)  Calls SDK \(SendBirdCall.sdkVersion)"
        
        let current = Calendar.current
        let year = current.component(.year, from: Date())
        self.copyrightLabel.text = "© \(year) SendBird"
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
