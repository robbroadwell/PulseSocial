//
//  ReportProblemViewController.swift
//  pulse
//
//  Created by Rob Broadwell on 1/21/18.
//  Copyright © 2018 Rob Broadwell LTD. All rights reserved.
//

import UIKit

class ReportProblemViewController: UIViewController {
 
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        textView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendPressed(_ sender: UIBarButtonItem) {
        textView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        textView.becomeFirstResponder()
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
            
            textViewBottomConstraint.constant = -(view.bounds.maxY - convertedKeyboardEndFrame.minY)
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
    }
}
