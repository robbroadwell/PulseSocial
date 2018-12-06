//
//  Blur.swift
//  pulse
//
//  Created by Rob Broadwell on 1/18/18.
//  Copyright © 2018 Rob Broadwell LTD. All rights reserved.
//

import UIKit

extension UIView {
 
    func blur() -> UIView {
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
        
    }
}
