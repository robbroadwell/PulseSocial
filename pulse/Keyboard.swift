//
//  Keyboard.swift
//  pulse
//
//  Created by Rob Broadwell on 11/29/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import UIKit

extension MapViewController: UITextFieldDelegate {
    
    func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification)
    }
    
    func updateBottomLayoutConstraintWithNotification(_ notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        
        textEntryView?.textFieldBottomConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textEntryView?.textField.resignFirstResponder()
        viewModel.newPost(atLocation: map.currentUserLocation(), withImage: (textEntryView?.imageView.image)!, withComment: textField.text!)
        containerView.animateOut()
        return true
    }
    
}
