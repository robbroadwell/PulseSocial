//
//  WelcomeViewController.swift
//  firebase-storyboards
//
//  Created by Rob Broadwell on 5/1/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
