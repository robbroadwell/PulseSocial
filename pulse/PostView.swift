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
        
        guard let score = viewModel.score,
            let imageURL = viewModel.imageURL,
            let time = viewModel.time,
            let favorite = viewModel.isFavorite else { return }
        
        if viewModel.image != nil {
            imageView.image = viewModel.image
        } else {
            imageView.sd_setImage(with: URL(string: imageURL))
        }

        scoreLabel.text = String(score)
        upvoteButton.setImage(favorite ? #imageLiteral(resourceName: "favorite") : #imageLiteral(resourceName: "ic_favorite_border"), for: .normal)
        timeLabel.text = timeAgoSinceDate(unix: time)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func upvoteWasPressed(_ sender: UIButton) {
        viewModel.favorite()
    }
    
    class func instanceFromNib() -> PostView {
        return UINib(nibName: "PostView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PostView
    }
}
