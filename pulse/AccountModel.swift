//
//  AccountModel.swift
//  pulse
//
//  Created by Rob Broadwell on 12/16/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation

var accountModel: AccountModel?

class AccountModel {
    
    var score: Int {
        return getUserScore()
    }
    
    var favorites = [String : PostViewModel]()
    var posts = [String : PostViewModel]()
    
    init() {
        createObserver()
    }
    
    func createObserver() {
        
        // user posts
        firebase.usersRef.child(uid).child("posts").observe(.value, with: { (snapshot) in
            guard let snapshot = snapshot.value as? NSDictionary else { return }
            self.posts = self.getPosts(fromSnapshot: snapshot)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateScore"), object: nil, userInfo: nil)
        })
        
        // user favorites
        firebase.usersRef.child(uid).child("favorites").observe(.value, with: { (snapshot) in
            guard let snapshot = snapshot.value as? NSDictionary else { return }
            self.favorites = self.getPosts(fromSnapshot: snapshot)
        })
    }
    
    private func getPosts(fromSnapshot snapshot: NSDictionary) -> [String : PostViewModel] {
        var dict = [String : PostViewModel]()
        
        for (key, value) in snapshot {
            if let x = value as? NSDictionary,
                let y = key as? String,
                let score = x["score"] as? Int,
                let time = x["time"] as? Float,
                let imageURL = x["image"] as? String,
                let user = x["user"] as? String,
                let message = x["message"] as? String {
                
                dict[y] = PostViewModel(key: y, score: score, time: time, imageURL: imageURL, user: user, message: message)
                
            }
        }
        
        return dict
    }
    
    private func getUserScore() -> Int {
        
        var score: Int = 0
        
        for (_, value) in self.posts {
            
            if let this = value.score {
                score = score + this
            }

        }
        
        return score
    }
}
