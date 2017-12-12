//
//  ImagePicker.swift
//  pulse
//
//  Created by Rob Broadwell on 11/29/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import UIKit

extension MapViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        showTextEntry(withImage: image)
    }
    
    func showTextEntry(withImage image: UIImage) {
        textEntryView = TextEntryView.instanceFromNib()
        textEntryView?.imageView.image = image
//        containerView.contain(view: textEntryView!)
//        containerView.animateIn()
        textEntryView?.clipsToBounds = true
        textEntryView?.textField.becomeFirstResponder()
        textEntryView?.textField.delegate = self
    }
}
