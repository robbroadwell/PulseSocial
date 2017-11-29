//
//  PostView.swift
//  pulse
//
//  Created by Rob Broadwell on 5/26/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit

class TextEntryView: UIView {
    
    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    class func instanceFromNib() -> TextEntryView {
        return UINib(nibName: "TextEntryView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TextEntryView
    }
    
}
