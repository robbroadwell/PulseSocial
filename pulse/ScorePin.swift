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
    
    @IBOutlet weak var inside: UIView!
    @IBOutlet weak var insideWidth: NSLayoutConstraint!
    @IBOutlet weak var insideHeight: NSLayoutConstraint!
    @IBOutlet weak var outside: UIView!
    @IBOutlet weak var outsideWidth: NSLayoutConstraint!
    @IBOutlet weak var outsideHeight: NSLayoutConstraint!
    
    
    
    var radius: CGFloat = 0 {
        didSet {
            inside.layer.cornerRadius = radius
            insideWidth.constant = radius * 2
            insideHeight.constant = radius * 2
            outside.layer.cornerRadius = radius + 2.5
            outsideWidth.constant = (radius + 2.5) * 2
            outsideHeight.constant = (radius + 2.5) * 2
        }
    }
    
    @IBOutlet weak var label: UILabel!
    
    class func instanceFromNib() -> ScorePin {
        return UINib(nibName: "ScorePin", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ScorePin
    }
    
}
