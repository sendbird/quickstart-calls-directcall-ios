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
    @IBOutlet weak var appIdTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var accessTokenTextField: UITextField!
    
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
        guard let appId = self.appIdTextField.text?.collapsed else {
            self.presentErrorAlert(message: "Please enter valid app ID")
            return
        }
        guard let userId = self.userIdTextField.text?.collapsed else {
            self.presentErrorAlert(message: "Please enter valid user ID")
            return
        }
        let accessToken = self.accessTokenTextField.text
        
        let credential = SendBirdCredentialManager.SendBirdCredential(appID: appId,
                                                                      userID: userId,
                                                                      accessToken: accessToken)
        
        // Refer to `SignInWithQRViewController.didSignIn`
        self.delegate?.didSignIn(credential: credential)
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
