//
//  RegisterViewController.swift
//  pulse
//
//  Created by Rob Broadwell on 12/18/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerButtonBottonConstraint: NSLayoutConstraint!
    @IBAction func registerButtonTouchUpInside(_ sender: UIButton) {
        if textEntered {
            register()
        }
    }
    
    @IBAction func pop(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        registerButton.backgroundColor = UIColor.lightGray
        usernameTextField.setBottomBorder()
        usernameTextField.becomeFirstResponder()
        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.setBottomBorder()
        passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for:
            UIControlEvents.editingChanged)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(termsPressed))
//        tap.numberOfTapsRequired = 1
//        termsLabel.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func register() {
        if let email = usernameTextField.text,
            let password = passwordTextField.text {
            
            print("# REGISTER - Attempting register with \(email) / \(password).")
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                
                if error == nil {
                    print("# REGISTER - Account registered.")
                    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                        if error == nil {
                            print("# LOGIN - Logged in...")
                            self.navigationController?.dismiss(animated: false, completion: nil)
                        } else {
                            print("# LOGIN - Something went wrong...")
                        }
                    }
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Try Again", style: .cancel)
                    alertController.addAction(cancel)
                    self.present(alertController, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    func termsPressed() {
        print("terms pressed")
    }
    
    func keyboardWillShowNotification(_ notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification)
    }
    
    func keyboardWillHideNotification(_ notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification)
    }
    
    func updateBottomLayoutConstraintWithNotification(_ notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        if let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue
        {
            
            let animationCurve = UIViewAnimationOptions.init(rawValue: UInt(rawAnimationCurve))
            let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
            
            registerButtonBottonConstraint.constant = (view.bounds.maxY - convertedKeyboardEndFrame.minY) + 30
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
    }
    
    @objc func textFieldDidChange() {
        if textEntered {
            registerButton.backgroundColor = UIColor.init(red: 14/255,
                                                          green: 6/255,
                                                          blue: 118/255, alpha: 1)
        } else {
            registerButton.backgroundColor = UIColor.lightGray
        }
    }
    
    var textEntered: Bool {
        if usernameTextField.text != "" && passwordTextField.text != "" {
            return true
        } else {
            return false
        }
    }
    

}

