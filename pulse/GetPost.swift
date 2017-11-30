//
//  GetPost.swift
//  pulse
//
//  Created by Rob Broadwell on 11/29/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation

extension Firebase {

    func getPost(fromKey key: String, completionHandler: @escaping (Post) -> ()) {
        postsRef.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let imageURL = value?["image"] as? String ?? ""
            let comment = value?["message"] as? String ?? ""
            let score = value?["score"] as? Int ?? 1
            
            completionHandler(Post(comment: comment, imageURL: imageURL, score: score))
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

}
