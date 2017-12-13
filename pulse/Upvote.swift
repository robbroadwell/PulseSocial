//
//  Upvote.swift
//  pulse
//
//  Created by Rob Broadwell on 12/13/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import Firebase

extension Firebase {
    
    func upvote(key: String) {
        getScore(fromKey: key) { (score) in
            let post = self.postsRef.child(key)
            post.updateChildValues(["score": score + 1])
        }
    }
    
}
