//
//  PostView.swift
//  pulse
//
//  Created by Rob Broadwell on 5/26/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit

class PostView: UIView, PostViewDelegate {
    
    class func instanceFromNib() -> PostView {
        return UINib(nibName: "PostView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PostView
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var viewModel: PostViewModel! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        imageView.setIndicatorStyle(.gray)
        imageView.sd_setImage(with: URL(string: viewModel.imageURL!))
        scoreLabel.text = String(viewModel.score!)
        timeLabel.text = viewModel.timestamp
    }

}

protocol PostViewDelegate {
    func updateUI()
}
