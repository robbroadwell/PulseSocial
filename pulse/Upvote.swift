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
            
            // increment the score on the post
            let post = self.postsRef.child(key)
            post.updateChildValues(["score": score + 1])
            
            // associate the favorite with this user
            let favorites = self.userFavoritesRef.child(uid)
            let child = favorites.child(key)
            child.setValue(["timestamp": Timestamp])
        }
    }
    
    func isFavorite(key: String, completionHandler: @escaping (Bool) -> ()) {
        userFavoritesRef.child(uid).child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            if let _ = value?["timestamp"] {
                completionHandler(true) // the record exists
            } else {
                completionHandler(false) // the record does not exist
            }
            
        }) { (error) in
            completionHandler(false) // something went wrong
        }
    }
}
