//
//  PostViewModel.swift
//  pulse
//
//  Created by Rob Broadwell on 12/13/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation

class PostViewModel {
    
    let firebase = Firebase()
    
    var key: String
    var imageURL: String?
    var score: Int?
    var timestamp: String?
    var user: String?
    var message: String?
    
    init(key: String) {
        self.key = key
        createObserver()
    }
    
    func createObserver() {
        
        firebase.postsRef.child(key).observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            self.imageURL = value?["image"] as? String ?? ""
            self.score = value?["score"] as? Int ?? 1
            self.timestamp = value?["timestamp"] as? String ?? ""
            self.user = value?["user"] as? String ?? ""
            self.message = value?["message"] as? String ?? ""
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func upvote() {
        let post = firebase.postsRef.child(key)
        post.updateChildValues(["score": score! + 1])

        let favorites = firebase.userFavoritesRef.child(uid)
        let child = favorites.child(key)
        child.setValue(["timestamp": timestamp])
    }

//    func downvote() {
//        let post = firebase.postsRef.child(key)
//        post.updateChildValues(["score": score! - 1])
//
//        let favorites = firebase.userFavoritesRef.child(uid)
//        let child = favorites.child(key)
//        child.setValue(["timestamp": timestamp])
//    }
    
}


