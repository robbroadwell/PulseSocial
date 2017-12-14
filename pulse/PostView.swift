//
//  PostView.swift
//  pulse
//
//  Created by Rob Broadwell on 5/26/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit

class PostView: UIView {
    
    class func instanceFromNib() -> PostView {
        return UINib(nibName: "PostView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PostView
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var post: PostViewModel! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        imageView.setIndicatorStyle(.gray)
        imageView.sd_setImage(with: URL(string: post.imageURL!))
        scoreLabel.text = String(post.score!)
        timeLabel.text = post.timestamp
    }
    
//    @IBAction func upvote(_ sender: Any) {
//        if !favorite {
//            let dict: [String : Any] = ["key": post.key]
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "upvote"), object: nil, userInfo: dict)
//            scoreLabel.text = String(post.score + 1) // temporary hack... need listeners
//            favorite = true
//        }
//    }

}
