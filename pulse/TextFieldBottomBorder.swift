//
//  TextFieldBottomBorder.swift
//  pulse
//
//  Created by Rob Broadwell on 12/18/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
}
