//
//  PostViewModel.swift
//  pulse
//
//  Created by Rob Broadwell on 12/13/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation

class PostViewModel {
    
    var delegate: PostViewDelegate?
    
    var key: String
    var score: Int?
    var time: Float?
    var imageURL: String?
    var user: String?
    var message: String?
    var isFavorite: Bool?
    
    init(key: String) {
        self.key = key
        createObserver()
    }
    
    func createObserver() {
        
        firebase.postsRef.child(key).observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            self.score = value?["score"] as? Int ?? 1
            self.time = value?["time"] as? Float ?? 1.0
            self.imageURL = value?["image"] as? String ?? ""
            self.user = value?["user"] as? String ?? ""
            self.message = value?["message"] as? String ?? ""
            self.isFavorite = self.checkIsFavorite(from: value?["favoritedBy"] as? NSDictionary)
            
            self.delegate?.updateUI()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func favorite() {
        
        let post = firebase.postsRef.child(key)
        let child = post.child("favoritedBy")
        
        if let fav = isFavorite {
            if fav {
                post.updateChildValues(["score": score! - 1])
                child.child(uid).removeValue()
                return
            }
        }
        
        post.updateChildValues(["score": score! + 1])
        child.child(uid).setValue(["time": timestamp])
    }
    
    func checkIsFavorite(from dictionary: NSDictionary?) -> Bool {
        if let dict = dictionary,
            let _ = dict[uid] {
            return true
        }
        return false
    }
    
    deinit {
        // destroy observer
        firebase.postsRef.child(key).removeAllObservers()
    }
    
}
