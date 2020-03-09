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
    // Call
    @IBOutlet weak var calleeIdTextField: UITextField!
    @IBOutlet weak var voiceCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
    
    // Button Image
    @IBOutlet weak var voiceCallImageView: UIImageView!
    @IBOutlet weak var videoCallImageView: UIImageView!

    // Constraints for Keyboard
    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!   // For interaction with audio setting switch
    
    // MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calleeIdTextField.delegate = self
        NotificationCenter.observeKeyboard(action1: #selector(keyboardWillShow(_:)), action2: #selector(keyboardWillHide(_:)), on: self)
        
        self.setupUI()
    }
    
    func setupUI() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.calleeIdTextField.frame.height))
        self.calleeIdTextField.leftView = paddingView
        self.calleeIdTextField.leftViewMode = UITextField.ViewMode.always
        
        self.voiceCallButton.isEnabled = false
        self.videoCallButton.isEnabled = false
        
        self.textFieldBottomConstraint.constant = 16
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "voiceCall", let voiceCallVC = segue.destination as? VoiceCallViewController, let call = sender as? DirectCall {
            voiceCallVC.isDialing = true
            voiceCallVC.call = call
        }
    }
}

// MARK: - User Interaction with SendBirdCall
extension DialViewController {
    
    @IBAction func didTapVoiceCall() {
        guard let calleeId = calleeIdTextField.filteredText, !calleeId.isEmpty else { return }
        self.voiceCallButton.isEnabled = false
        
        // MARK: SendBirdCall.dial()
        let callOptions = CallOptions(isAudioEnabled: true)
        let dialParams = DialParams(calleeId: calleeId, isVideoCall: false, callOptions: callOptions, customItems: [:])

        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async { [weak self] in
                self?.voiceCallButton.isEnabled = true
            }
            
            guard error == nil, let call = call else {
                DispatchQueue.main.async { [weak self] in
                    self?.alertError(message: "Failed to call\nError: \(String(describing: error?.localizedDescription))")
                }
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.performSegue(withIdentifier: "voiceCall", sender: call)
            }
        }
    }
    
    @IBAction func didTapVideoCall() {
        guard let calleeId = calleeIdTextField.filteredText, !calleeId.isEmpty else { return }
        self.videoCallButton.isEnabled = false
        
        // MARK: SendBirdCall.dial()
        let callOptions = CallOptions(isAudioEnabled: true)
        let dialParams = DialParams(calleeId: calleeId, isVideoCall: true, callOptions: callOptions, customItems: [:])

        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async { [weak self] in
                self?.voiceCallButton.isEnabled = true
            }
            
            guard error == nil, let call = call else {
                DispatchQueue.main.async { [weak self] in
                    self?.alertError(message: "Failed to make video call\nError: \(String(describing: error?.localizedDescription))")
                }
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.performSegue(withIdentifier: "videoCall", sender: call)
            }
        }
    }
}

// MARK: - Setting Up UI
extension DialViewController {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
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
            self.voiceCallImageView.alpha = 0.0
            self.voiceCallButton.alpha = 0.0
            
            self.videoCallImageView.alpha = 0.0
            self.videoCallButton.alpha = 0.0
            
            self.view.layoutIfNeeded()
        }

        animator.startAnimation()
    }
    
    // MARK: When Keyboard Hide
    @objc func keyboardWillHide(_ notification: Notification) {
        var value: CGFloat = 40.0
        if let text = self.calleeIdTextField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            value = 200
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.voiceCallImageView.alpha = 1.0
            self.voiceCallButton.alpha = 1.0
            self.voiceCallButton.isEnabled = true
            
            self.videoCallImageView.alpha = 1.0
            self.videoCallButton.alpha = 1.0
            self.videoCallButton.isEnabled = true
            
            self.textFieldBottomConstraint.constant = value
            self.view.layoutIfNeeded()
        })
    }
}

