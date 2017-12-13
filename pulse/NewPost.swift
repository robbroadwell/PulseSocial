//
//  NewPost.swift
//  pulse
//
//  Created by Rob Broadwell on 11/29/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import Firebase
import GeoFire

extension Firebase {
    
    func newPost(atLocation coordinate: CLLocationCoordinate2D, withImage image: UIImage, withComment comment: String) {
        
        let key = Hash.generate()
        
        var imageData = Data()
        imageData = UIImageJPEGRepresentation(image, 0)!
        
        uploadImage(key: key, data: imageData) { (imageURL) in
            
            self.createPost(key: key, message: comment, imageURL: imageURL)
            self.createGeoPost(key: key, latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.createUserPost(key: key)
            
        }
    }
    
    private func uploadImage(key: String, data: Data, completionHandler: @escaping (String) -> ()) {
        
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
    
    private func createPost(key: String, message: String, imageURL: String) {
        let post = postsRef.child(key)
        post.setValue(["message": message,
                       "timestamp": Timestamp,
                       "score": 1,
                       "image": imageURL,
                       "user": uid])
    }
    
    private func createGeoPost(key: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        geoFire.setLocation(CLLocation(latitude: latitude, longitude: longitude), forKey: key)
    }
    
    private func createUserPost(key: String) {
        let user = userPostsRef.child(uid)
        let userPost = user.child(key)
        userPost.setValue(["score": 0])
    }
    
}
