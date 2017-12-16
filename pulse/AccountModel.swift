//
//  AccountModel.swift
//  pulse
//
//  Created by Rob Broadwell on 12/16/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation

class AccountModel {
    
    var score: Int!
    var delegate: AccountDelegate?
    
    init() {
        createObserver()
    }
    
    func createObserver() {
        
        firebase.usersRef.child(uid).child("posts").observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            self.score = self.getUserScore(from: value)
            
            self.delegate?.updateUI()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
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
