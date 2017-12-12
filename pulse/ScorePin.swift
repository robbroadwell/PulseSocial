//
//  ScorePin.swift
//  pulse
//
//  Created by Rob Broadwell on 12/12/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import UIKit

class ScorePin: UIView {
    
    @IBOutlet weak var label: UILabel!
    
    class func instanceFromNib() -> ScorePin {
        return UINib(nibName: "ScorePin", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ScorePin
    }
    
}
