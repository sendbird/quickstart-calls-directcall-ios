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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "voiceCall", let voiceCallVC = segue.destination as? VoiceCallViewController, let call = sender as? DirectCall {
            voiceCallVC.isDialing = true
            voiceCallVC.call = call
        } else if segue.identifier == "videoCall", let videoCallVC = segue.destination as? VideoCallViewController, let call = sender as? DirectCall {
            videoCallVC.isDialing = true
            videoCallVC.call = call
        }
    }
}

// MARK: - User Interaction with SendBirdCall
extension DialViewController {
    
    @IBAction func didTapVoiceCall() {
        guard let calleeId = calleeIdTextField.filteredText, !calleeId.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                self?.alertError(message: "Please enter user ID")
            }
            return
        }
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
        guard let calleeId = calleeIdTextField.filteredText, !calleeId.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                self?.alertError(message: "Please enter user ID")
            }
            return
        }
        self.videoCallButton.isEnabled = false
        
        // MARK: SendBirdCall.dial()
        let callOptions = CallOptions(isAudioEnabled: true, isVideoEnabled: true)
        let dialParams = DialParams(calleeId: calleeId, isVideoCall: true, callOptions: callOptions, customItems: [:])

        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async { [weak self] in
                self?.videoCallButton.isEnabled = true
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
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            self.calleeIdTextField.layer.borderWidth = 1.0
            self.voiceCallButton.alpha = 0.0
            self.videoCallButton.alpha = 0.0
            
            self.view.layoutIfNeeded()
        }

        animator.startAnimation()
    }
    
    // MARK: When Keyboard Hide
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.calleeIdTextField.layer.borderWidth = 0.0
            self.voiceCallButton.alpha = 1.0
            self.voiceCallButton.isEnabled = true
        
            self.videoCallButton.alpha = 1.0
            self.videoCallButton.isEnabled = true
            
            self.view.layoutIfNeeded()
        })
    }
}

