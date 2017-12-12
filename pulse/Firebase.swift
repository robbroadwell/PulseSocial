//
//  Firebase.swift
//  pulse
//
//  Created by Rob Broadwell on 11/29/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import GeoFire

class Firebase {
    
    let showScoreOnPins = false
    
    // Realtime Database
    var firebase: DatabaseReference!
    var postsRef: DatabaseReference!
    var geoPostsRef: DatabaseReference!
    var userPostsRef: DatabaseReference!
    
    // Cloud Storage
    var storage = Storage.storage()
    var storageRef: StorageReference!
    var imagesRef: StorageReference!
    
    // Geofire
    var geoFire: GeoFire!
    var regionQuery: GFRegionQuery?
    
    init() {
        initializeRealtimeDatabase()
        initializeCloudStorage()
    }
    
    private func initializeRealtimeDatabase() {
        firebase = Database.database().reference()
        postsRef = firebase.child("posts")
        geoPostsRef = firebase.child("geoPosts")
        userPostsRef = firebase.child("userPosts")
        geoFire = GeoFire(firebaseRef: geoPostsRef)
    }
    
    private func initializeCloudStorage() {
        storageRef = storage.reference()
        imagesRef = storageRef.child("images")
    }
    
    func updateMapRegion(to region: MKCoordinateRegion) {
        
        if regionQuery == nil {
            
            // Update region on GeoFire query
            regionQuery = geoFire.query(with: region)
            
            // Create listener for posts entering the screen region
            regionQuery?.observe(.keyEntered, with: { (key, location) in // observer of new post objects in region
                if let key = key,
                    let location = location {
                    
                    // get the full post
                    self.getPost(fromKey: key, completionHandler: { (post) in
                        let dict: [String : Any] = ["key": key, "location": location, "post": post]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addPost"), object: nil, userInfo: dict)
                    })
                    
                }
            })
            
            // Create listener for posts leaving the screen region
            regionQuery?.observe(.keyExited, with: { (key, location) in // observer of deletion of post objects in region
                if let key = key {
                    
                    let dict: [String : Any] = ["key": key]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removePost"), object: nil, userInfo: dict)
                }
            })
            
        } else {
            regionQuery?.region = region // update the screen region
        }
    }
}
