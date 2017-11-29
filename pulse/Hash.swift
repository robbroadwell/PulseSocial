//
//  Hash.swift
//  pulse
//
//  Created by Rob Broadwell on 5/25/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation

class Hash {
    
    func generate(length: Int = 8) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
