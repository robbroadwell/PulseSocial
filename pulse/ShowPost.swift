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
        containerView.contain(view: postView)
        postView.clipsToBounds = true
        postView.imageView.setShowActivityIndicator(true)
        
        containerViewTopConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        postView.imageView.setIndicatorStyle(.gray)
        postView.imageView.sd_setImage(with: URL(string: post.imageURL))
        
        isShowingPost = true
    }
    
    func hidePost() {
        containerViewTopConstraint.constant = screenHeight
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}
