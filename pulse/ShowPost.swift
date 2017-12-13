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
    
    func show(_ post: Post) {
        
        let postView = PostView.instanceFromNib()
        postView.clipsToBounds = true
        postView.imageView.setShowActivityIndicator(true)
        postView.post = post
        
        firebase.isFavorite(key: post.key) { (bool) in
            postView.favorite = bool
        }
        
        containerView.contain(view: postView)
        containerViewTopConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        isShowingPost = true
    }
    
    func hidePost() {
        containerViewTopConstraint.constant = screenHeight
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}
