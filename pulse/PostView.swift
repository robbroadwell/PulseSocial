//
//  PostView.swift
//  pulse
//
//  Created by Rob Broadwell on 5/26/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit

class PostView: UIView {
    
    var post: Post! {
        didSet {
            imageView.setIndicatorStyle(.gray)
            imageView.sd_setImage(with: URL(string: post.imageURL))
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func upvote(_ sender: Any) {
        let dict: [String : Any] = ["key": post.key]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "upvote"), object: nil, userInfo: dict)
    }
    
    class func instanceFromNib() -> PostView {
        return UINib(nibName: "PostView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PostView
    }

}
