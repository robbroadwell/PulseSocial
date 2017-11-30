//
//  ViewModel.swift
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

class ViewModel {
    
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
                    
                    let dict: [String : Any] = ["key": key, "location": location]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addPost"), object: nil, userInfo: dict)
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
    
    func newPost(atLocation coordinate: CLLocationCoordinate2D, withImage image: UIImage, withComment comment: String) {
        
        let key = Hash.generate()
        let uid = Auth.auth().currentUser?.uid
        
        var imageData = Data()
        imageData = UIImageJPEGRepresentation(image, 0)!
        
        uploadImage(key: key, data: imageData) { (imageURL) in
            
            self.createPost(key: key, message: comment, imageURL: imageURL, uid: uid!)
            self.createGeoPost(key: key, latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.createUserPost(key: key, uid: uid!)
            
        }
    }
}

extension ViewModel {
    
    fileprivate func uploadImage(key: String, data: Data, completionHandler: @escaping (String) -> ()) {
        
        let thisImageRef = self.imagesRef.child(key)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        thisImageRef.putData(data, metadata: metaData) { metadata, error in
            if error != nil {
                print("there was an error uploading the file")
            } else {
                completionHandler(metadata!.downloadURL()!.absoluteString)
            }
        }
    }
    
    fileprivate func createPost(key: String, message: String, imageURL: String, uid: String) {
        let post = postsRef.child(key)
        post.setValue(["message": message,
                       "timestamp": NSDate().timeIntervalSince1970,
                       "score": 1,
                       "image": imageURL,
                       "user": uid])
    }
    
    fileprivate func createGeoPost(key: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        geoFire.setLocation(CLLocation(latitude: latitude, longitude: longitude), forKey: key)
    }
    
    fileprivate func createUserPost(key: String, uid: String) {
        let user = userPostsRef.child(uid)
        let userPost = user.child(key)
        userPost.setValue(["score": 0])
    }
    
}
