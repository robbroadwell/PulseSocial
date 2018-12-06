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
    
    var score: Int!
    
    init() {
        createObserver()
    }
    
    func createObserver() {
        
        firebase.usersRef.child(uid).child("posts").observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            self.score = self.getUserScore(from: value)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateScore"), object: nil, userInfo: nil)
            
        })
        
    }
    
    func getUserScore(from dictionary: NSDictionary?) -> Int {
        
        var score = 0
        
        if let dict = dictionary {
            for post in dict {
                
                if let x = post.value as? NSDictionary,
                    let y = x["score"] as? Int {
                    
                    score = score + y
                }
            }
        }
        
        return score
    }
}
