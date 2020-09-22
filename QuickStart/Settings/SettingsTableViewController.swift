//
//  SettingsTableViewController.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    
    @IBOutlet weak var versionLabel: UILabel! {
        didSet {
            let sampleVersion = Bundle.main.version
            self.versionLabel.text = "QuickStart \(sampleVersion)   SDK \(SendBirdCall.sdkVersion)"
        }
    }
    
    enum CellRow: Int {
        case applnfo = 1
        case signOut = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To receive event when the credential has been updated
        CredentialManager.shared.addDelegate(self, forKey: "Settings")
        
        // Set up UI with current credential
        self.updateUI(with: UserDefaults.standard.credential)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch CellRow(rawValue: indexPath.row) {
        case .applnfo:
            self.performSegue(withIdentifier: "appInfo", sender: nil)
        case .signOut:
            let alert = UIAlertController(title: "Do you want to sign out?",
                                          message: "If you sign out, you cannot receive any calls.",
                                          preferredStyle: .alert)
            
            let actionSignOut = UIAlertAction(title: "Sign Out", style: .default) { _ in
                // MARK: Sign Out
                self.signOut { error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.presentErrorAlert(message: error.localizedDescription)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.present(UIStoryboard.signController(), animated: true, completion: nil)
                    }
                }
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(actionSignOut)
            alert.addAction(actionCancel)
            
            self.present(alert, animated: true, completion: nil)
        default: return
        }
    }
}

// MARK: - SendBirdCall Interaction
extension SettingsTableViewController {
    func signOut(_ completionHandler: @escaping ((_ error: Error?) -> Void)) {
        let logOut: (() -> Void) = {
            // MARK: SendBirdCall Deauthenticate
            SendBirdCall.deauthenticate { error in
                if error == nil { UserDefaults.standard.clear() }
                CredentialManager.shared.updateCredential(UserDefaults.standard.credential)
                completionHandler(error)
            }
        }
        
        if let token = UserDefaults.standard.voipPushToken {
            SendBirdCall.unregisterVoIPPush(token: token) { error in
                // Handle error
                print("[QuickStart] Unregister VoIP Push Token with error: \(String(describing: error?.localizedDescription))")
                logOut()
            }
        } else {
            logOut()
        }
    }
}

// MARK: - Credential Delegate
extension SettingsTableViewController: CredentialDelegate {
    func didUpdateCredential(_ credential: Credential?) {
        self.updateUI(with: credential)
    }
    
    func updateUI(with credential: Credential?) {
        let profileURL = credential?.profileURL
        self.userProfileImageView.updateImage(urlString: profileURL)
        self.usernameLabel.text = credential?.nickname.unwrap(with: "-")
        self.userIdLabel.text = "User ID: " + (credential?.userId ?? "-")
    }
}
