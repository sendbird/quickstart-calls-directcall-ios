//
//  AccountTableViewController.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdCalls


class AccountTableViewController: UITableViewController {
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var signOutView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSignOutButton()
        self.setupUserInfo()
    }
    
    func setupSignOutButton() {
        self.signOutView.layer.cornerRadius = self.signOutView.frame.height / 4
        self.signOutView.layer.masksToBounds = true
        self.signOutView.backgroundColor = .systemPink
        self.signOutView.alpha = 0.7
    }
    
    func setupUserInfo() {
        self.userIdLabel.text = "User Id: \(UserDefaults.standard.user.id)"
        
        if let nickname = UserDefaults.standard.user.name {
            self.usernameLabel.text = "\(nickname)"
        } else {
            self.usernameLabel.text = ""
        }
        
        let defaultImage = "https://static.sendbird.com/sample/profiles/profile_09_512px.png"
        let profile: String = UserDefaults.standard.user.profile ?? defaultImage
        
        if let profileURL = URL(string: profile) {
            do {
                let data = try Data(contentsOf: profileURL)
                self.userProfileImageView.image = UIImage(data: data)
                self.userProfileImageView.rounding()
            } catch {
                print("[QuickStart] Failed to decode image")
            }
        }
        
        userIdLabel.textColor = .lightPurple
        usernameLabel.textColor = .purple
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {        
        // Sign Out
        case 1:
            self.signOutView.alpha = 0.3
            
            let alert = UIAlertController(title: "Do you want to sign out?", message: "If you sign out, you cannot receive any calls.", preferredStyle: .alert)
            
            let actionSignOut = UIAlertAction(title: "Sign Out", style: .default) { _ in
                // MARK: Sign Out
                self.signOut()
                DispatchQueue.main.async {
                    UserDefaults.standard.autoLogin = false
                    self.dismiss(animated: true, completion: nil)
                }
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                let animator = UIViewPropertyAnimator(duration: 0.1, curve: .easeIn) {
                    self.signOutView.alpha = 0.7
                }
                animator.startAnimation()
            }
            alert.addAction(actionSignOut)
            alert.addAction(actionCancel)
            
            self.present(alert, animated: true, completion: nil)
            
        default: return
        }
    }
}

// MARK: - SendBirdCall Interaction
extension AccountTableViewController {
    func signOut() {
        guard let token = UserDefaults.standard.pushToken else { return }
        
        // MARK: SendBirdCall Deauthenticate
        SendBirdCall.deauthenticate(pushToken: token) { error in
            guard error == nil else { return }
            // Removed pushToken successfully
            UserDefaults.standard.pushToken = nil
        }
    }
}

