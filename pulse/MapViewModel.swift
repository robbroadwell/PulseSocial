//
//  MapViewModel.swift
//  pulse
//
//  Created by Rob Broadwell on 12/13/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import GeoFire
//
//class MapViewModel {
//    
//    var posts = [String : PostViewModel]()
//    let firebase = Firebase()
//    
//    // Geofire
//    var geoFire: GeoFire!
//    var firebaseRef: DatabaseReference!
//    var geoPostsRef: DatabaseReference!
//    var regionQuery: GFRegionQuery?
//    
//    init() {
//        firebaseRef = Database.database().reference()
//        geoPostsRef = firebaseRef.child("geoPosts")
//        geoFire = GeoFire(firebaseRef: geoPostsRef)
//    }
//    
//    func update(mapRegion: MKCoordinateRegion) {
//        
//        if regionQuery == nil {
//            
//            // Update region on GeoFire query
//            regionQuery = geoFire.query(with: mapRegion)
//            
//            // Create listener for posts entering the screen region
//            regionQuery?.observe(.keyEntered, with: { (key, location) in // observer of new post objects in region
//                if let key = key,
//                    let location = location {
//                    
//                    let dict: [String : Any] = ["key": key, "location": location]
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addPost"), object: nil, userInfo: dict)
//                    
//                    self.posts[key] = PostViewModel(key: key)
//                    
//                }
//            })
//            
//            // Create listener for posts leaving the screen region
//            regionQuery?.observe(.keyExited, with: { (key, location) in // observer of deletion of post objects in region
//                if let key = key {
//                    
//                    let dict: [String : Any] = ["key": key]
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removePost"), object: nil, userInfo: dict)
//                    
//                    self.posts.removeValue(forKey: key)
//                }
//            })
//            
//        } else {
//            regionQuery?.region = mapRegion // update the screen region
//        }
//    }
//    
//}

