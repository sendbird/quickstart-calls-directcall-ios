//
//  AppInfoTableViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/03/12.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

class AppInfoViewController: UIViewController {
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var appIdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    func setupUI() {
        self.appNameLabel.text = Bundle.main.appName ?? "No app name"
        self.appIdLabel.text = SendBirdCall.appId ?? "No configured app ID"
    }
}
