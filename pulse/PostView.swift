//
//  PostView.swift
//  pulse
//
//  Created by Rob Broadwell on 5/26/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit

protocol PostViewDelegate {
    func updateUI()
}

class PostView: UIView, PostViewDelegate {
    
    var viewModel: PostViewModel!
    
    func updateUI() {
        imageView.setIndicatorStyle(.gray)
        imageView.sd_setImage(with: URL(string: viewModel.imageURL!))
        scoreLabel.text = String(viewModel.score!)
        timeLabel.text = viewModel.time
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func upvoteWasPressed(_ sender: Any) {
        viewModel.upvote()
    }

    class func instanceFromNib() -> PostView {
        return UINib(nibName: "PostView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PostView
    }
}
