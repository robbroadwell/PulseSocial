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
    
//    func login() {
//        if let email = usernameTextField.text,
//            let password = passwordTextField.text {
//            
//            print("# LOGIN - Attempting login with \(email) / \(password).")
//            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
//                print("# LOGIN - Logged in...")
//            }
//        }
//    }
//    
//    func register() {
//        if let email = usernameTextField.text,
//            let password = passwordTextField.text {
//            
//            print("# REGISTER - Attempting register with \(email) / \(password).")
//            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
//                print("# REGISTER - Logged in...")
//            }
//        }
//    }
}
