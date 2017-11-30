//
//  LoginViewController.swift
//  firebase-storyboards
//
//  Created by Rob Broadwell on 5/1/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    enum mode {
        case login
        case register
    }
    
    var activeMode = mode.login
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func loginButtonWasPressed(_ sender: Any) {
        loginButton.setTitleColor(UIColor.black, for: .normal)
        registerButton.setTitleColor(UIColor.blue, for: .normal)
        activeMode = .login
    }
    
    @IBAction func registerButtonWasPressed(_ sender: Any) {
        loginButton.setTitleColor(UIColor.blue, for: .normal)
        registerButton.setTitleColor(UIColor.black, for: .normal)
        activeMode = .register
    }
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func submitButtonWasPressed(_ sender: Any) {
        
        if activeMode == .login {
            login()
        }
        
        if activeMode == .register {
            register()
        }
    }
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        
        handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            if Auth.auth().currentUser != nil {
                self.dismiss(animated: true, completion: nil)
            } else {

            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func login() {
        if let email = usernameTextField.text,
            let password = passwordTextField.text {
            
            print("# LOGIN - Attempting login with \(email) / \(password).")
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                print("# LOGIN - Logged in...")
            }
        }
    }
    
    func register() {
        if let email = usernameTextField.text,
            let password = passwordTextField.text {
            
            print("# REGISTER - Attempting register with \(email) / \(password).")
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                print("# REGISTER - Logged in...")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // hide keyboard
    }
}
