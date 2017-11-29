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
        print(usernameTextField.text ?? "unable to cast username as string")
        print(passwordTextField.text ?? "unable to cast password as string")
        
        if activeMode == .login {
            attemptLogin()
        }
        
        if activeMode == .register {
            attemptRegister()
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
    
    func attemptLogin() {
        print("attempting login with \(usernameTextField.text) // \(passwordTextField.text)")
        
        Auth.auth().signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!) { (user, error) in
            
        }
    }
    
    func attemptRegister() {
        print("attempting register with \(usernameTextField.text) // \(passwordTextField.text)")
        
        Auth.auth().createUser(withEmail: usernameTextField.text!, password: passwordTextField.text!) { (user, error) in
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // hide keyboard
    }
}
