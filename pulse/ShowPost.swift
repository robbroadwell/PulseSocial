//
//  ShowPost.swift
//  pulse
//
//  Created by Rob Broadwell on 11/29/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import UIKit

extension MapViewController {
    
    func showPost(withKey key: String) {
        
        let postView = PostView.instanceFromNib()
//        containerView.contain(view: postView)
        postView.clipsToBounds = true
        postView.comment.alpha = 0
//        self.containerView.animateIn()
        
        firebase.getPost(fromKey: key) { (post) in
            postView.comment.text = post.comment
            UIView.animate(withDuration: 0.2, animations: {
                postView.comment.alpha = 1
            })
            postView.imageView.setShowActivityIndicator(true)
            postView.imageView.setIndicatorStyle(.gray)
            postView.imageView.sd_setImage(with: URL(string: post.imageURL))
        }
    }
    
    func hidePost() {
//        containerView.animateOut()
    }
    
}
