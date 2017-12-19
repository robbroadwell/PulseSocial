//
//  LoginViewController.swift
//  pulse
//
//  Created by Rob Broadwell on 12/18/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBAction func pop(_ sender: Any) {
        self.navigationController?.dismiss(animated: false, completion: nil)
    }
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonBottomConstraint: NSLayoutConstraint!
    
    @IBAction func forgotPasswordTouchUpInside(_ sender: UIButton) {
        
    }
    
    @IBAction func loginTouchUpInside(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        loginButton.backgroundColor = UIColor.lightGray
        usernameTextField.setBottomBorder()
        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.setBottomBorder()
        passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: 
            UIControlEvents.editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
                
                loginButtonBottomConstraint.constant = (view.bounds.maxY - convertedKeyboardEndFrame.minY) + 30
                
                UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
        }
    }
    
    @objc func textFieldDidChange() {
        if usernameTextField.text != "" && passwordTextField.text != "" {
            loginButton.backgroundColor = UIColor.red
        } else {
            loginButton.backgroundColor = UIColor.lightGray
        }
    }
    
}
