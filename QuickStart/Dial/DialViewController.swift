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
    // Profile
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            let profileURL = UserDefaults.standard.user.profile
            self.profileImageView.setImage(urlString: profileURL)
        }
    }
    @IBOutlet weak var userIdLabel: UILabel! {
        didSet {
            self.userIdLabel.text = UserDefaults.standard.user.id
        }
    }
    
    // Call
    @IBOutlet weak var calleeIdTextField: UITextField! {
        didSet {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.calleeIdTextField.frame.height))
            self.calleeIdTextField.leftView = paddingView
            self.calleeIdTextField.leftViewMode = UITextField.ViewMode.always
        }
    }
    @IBOutlet weak var voiceCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
    
    let activityIndicator = UIActivityIndicatorView()
    
    // MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calleeIdTextField.delegate = self
        NotificationCenter.observeKeyboard(action1: #selector(keyboardWillShow(_:)), action2: #selector(keyboardWillHide(_:)), on: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var dataSource = segue.destination as? DirectCallDataSource, let call = sender as? DirectCall {
            dataSource.call = call
            dataSource.isDialing = true
        }
    }
}

// MARK: - User Interaction with SendBirdCall
extension DialViewController {
    @IBAction func didTapVoiceCall() {
        guard let calleeId = calleeIdTextField.filteredText, !calleeId.isEmpty else {
            self.presentErrorAlert(message: "Enter a valid user ID")
            return
        }
        self.voiceCallButton.isEnabled = false
        self.startLoading()
        
        // MARK: SendBirdCall.dial()
        let callOptions = CallOptions(isAudioEnabled: true)
        let dialParams = DialParams(calleeId: calleeId, isVideoCall: false, callOptions: callOptions, customItems: [:])

        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.voiceCallButton.isEnabled = true
                self.stopLoading()
            }
            
            guard error == nil, let call = call else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let errorDescription = String(error?.localizedDescription ?? "")
                    self.presentErrorAlert(message: "Failed to call\n\(errorDescription)")
                }
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.performSegue(withIdentifier: "voiceCall", sender: call)
            }
        }
    }
    
    @IBAction func didTapVideoCall() {
        guard let calleeId = calleeIdTextField.filteredText, !calleeId.isEmpty else {
            self.presentErrorAlert(message: "Please enter user ID")
            return
        }
        self.videoCallButton.isEnabled = false
        self.startLoading()
        
        // MARK: SendBirdCall.dial()
        let callOptions = CallOptions(isAudioEnabled: true, isVideoEnabled: true, useFrontCamera: true)
        let dialParams = DialParams(calleeId: calleeId, isVideoCall: true, callOptions: callOptions, customItems: [:])

        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.videoCallButton.isEnabled = true
                self.stopLoading()
            }
            
            guard error == nil, let call = call else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let errorDescription = String(error?.localizedDescription ?? "")
                    self.presentErrorAlert(message: "Failed to make video call\n\(errorDescription)")
                }
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.performSegue(withIdentifier: "videoCall", sender: call)
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
}

