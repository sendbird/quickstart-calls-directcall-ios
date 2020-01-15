//
//  DialViewController.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import CallKit
import SendBirdCalls

class DialViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var calleeIdTextField: UITextField!
    @IBOutlet weak var dialButton: UIButton!
    @IBOutlet weak var muteAudioButton: UIButton!

    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!   // For interaction with audio setting switch
    @IBOutlet weak var dialButtonCenterConstraint: NSLayoutConstraint!  // For interaction with keyboard
    
    @IBOutlet weak var audioMutedView: UIView!
    @IBOutlet weak var audioMutedSwitch: UISwitch!
    
    var isMyAudioEnabled: Bool {
        return !audioMutedSwitch.isOn
    }
    
    // MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calleeIdTextField.delegate = self
        NotificationCenter.observeKeyboard(action1: #selector(keyboardWillShow(_:)), action2: #selector(keyboardWillHide(_:)), on: self)
        
        self.setupUI()
    }
    
    func setupUI() {
        self.calleeIdTextField.placeholder = "Enter User ID You Want to Call"
        
        self.dialButton.smoothAndWider()
        self.dialButton.setTitle("Call")
        self.dialButton.isEnabled = false
        self.muteAudioButton.setupAudioOption(isOn: isMyAudioEnabled)
        self.audioMutedView.alpha = 0.0
        self.textFieldBottomConstraint.constant = 16
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Calling", let callingVC = segue.destination as? CallingViewController, let call = sender as? DirectCall {
            callingVC.isDialing = true
            callingVC.call = call
        }
    }
    
    // MARK: Showing up Account
    @IBAction func didTapAccount(_ sender: Any) {
        performSegue(withIdentifier: "Account", sender: nil)
    }
}

// MARK: - User Interaction with SendBirdCall
extension DialViewController {
    
    @IBAction func didTapDial() {
        guard let calleeId = calleeIdTextField.filteredText, !calleeId.isEmpty else { return }
        self.dialButton.isEnabled = false
        
        // MARK: SendBirdCall.dial()
        let callOptions = CallOptions(isVideoCall: false, isAudioEnabled: self.isMyAudioEnabled)

        SendBirdCall.dial(to: calleeId, callOptions: callOptions) { call, error in
            DispatchQueue.main.async {
                self.dialButton.isEnabled = true
            }
            
            guard error == nil, let call = call else {
                DispatchQueue.main.async {
                    self.alertError(message: "Failed to call\nError: \(String(describing: error?.localizedDescription))")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "Calling", sender: call)
            }
        }
    }
}

// MARK: - Setting Up UI
extension DialViewController {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        audioMutedView.alpha = 0.0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let text = textField.filteredText, !text.isEmpty else { return false }
        return true
    }
    
    // MARK: When Keyboard Show
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrameBegin = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else  { return }
        let keyboardFrameBeginRect = keyboardFrameBegin.cgRectValue
        let keyboardHeight = keyboardFrameBeginRect.size.height
        
        let bottomOfTextField = view.frame.maxY - calleeIdTextField.frame.maxY
        let safeArea = keyboardHeight + 8.0
        let gap = bottomOfTextField - safeArea
            
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            if bottomOfTextField < safeArea {
                
                self.textFieldBottomConstraint.constant = self.textFieldBottomConstraint.constant + gap
            }
            self.dialButton.alpha = 0.0
            self.view.layoutIfNeeded()
        }

        animator.startAnimation()
    }
    
    // MARK: When Keyboard Hide
    @objc func keyboardWillHide(_ notification: Notification) {
        var value: CGFloat = 16.0
        var hideMuteOptionView = true
        if let text = self.calleeIdTextField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            value = 200
            hideMuteOptionView = false
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.dialButton.alpha = 1.0
            self.dialButton.isEnabled = true
            self.audioMutedView.alpha = hideMuteOptionView ? 0.0 : 1.0
            self.textFieldBottomConstraint.constant = value
            self.view.layoutIfNeeded()
        })
    }
}

