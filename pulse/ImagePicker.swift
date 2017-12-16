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
        firebase.newPost(atLocation: user.currentLocation.coordinate, withImage: image, withComment: "")
        mapView.moveTo(location: user.currentLocation, animated: true, spanDelta: 0.001)
    }

}
