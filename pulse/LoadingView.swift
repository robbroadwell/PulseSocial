//
//  LoadingView.swift
//  pulse
//
//  Created by Rob Broadwell on 12/18/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    } 
    
}
