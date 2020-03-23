//
//  SignInManuallyViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/23.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

class SignInManuallyViewController: UIViewController {
    @IBOutlet weak var appIdTextField: UITextField! {
        didSet {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.appIdTextField.frame.height))
            self.appIdTextField.leftView = paddingView
            self.appIdTextField.leftViewMode = UITextField.ViewMode.always
            self.appIdTextField.delegate = self
        }
    }
    
    @IBOutlet weak var userIdTextField: UITextField! {
        didSet {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.userIdTextField.frame.height))
            self.userIdTextField.leftView = paddingView
            self.userIdTextField.leftViewMode = UITextField.ViewMode.always
            self.userIdTextField.delegate = self
        }
    }
    
    @IBOutlet weak var accessTokenTextField: UITextField! {
        didSet {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.accessTokenTextField.frame.height))
            self.accessTokenTextField.leftView = paddingView
            self.accessTokenTextField.leftViewMode = UITextField.ViewMode.always
            self.accessTokenTextField.delegate = self
        }
    }
    
    @IBOutlet weak var versionLabel: UILabel! {
        didSet {
            let sampleVersion = Bundle.main.version
            self.versionLabel.text = "QuickStart \(sampleVersion)  Calls SDK \(SendBirdCall.sdkVersion)"
        }
    }
    
    weak var delegate: SignInDelegate?
    
    @IBAction func didTapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - ManualSignInDelegate
    @IBAction func didTapSignIn() {
        guard let appId = self.appIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !appId.isEmpty else {
            self.presentErrorAlert(message: "Please enter valid app ID")
            return
        }
        guard let userId = self.userIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !userId.isEmpty else {
            self.presentErrorAlert(message: "Please enter valid user ID")
            return
        }
        let accessToken = self.accessTokenTextField.text
        
        self.delegate?.didSignIn(appId: appId, userId: userId, accessToken: accessToken)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension SignInManuallyViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            textField.layer.borderWidth = 0.0
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            textField.layer.borderWidth = 1.0
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}
