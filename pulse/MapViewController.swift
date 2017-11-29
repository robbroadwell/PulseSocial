//
//  ViewController.swift
//  pulse
//
//  Created by Rob Broadwell on 5/23/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RxSwift
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SDWebImage
import GeoFire

extension MapViewController: UITextFieldDelegate {
    
    func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification)
    }
    
    func updateBottomLayoutConstraintWithNotification(_ notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        
        textEntryView?.textFieldBottomConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textEntryView?.textField.resignFirstResponder()
        viewModel.newPost(atLocation: map.currentUserLocation(), withImage: (textEntryView?.imageView.image)!, withComment: textField.text!)
        containerView.animateOut()
        return true
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = NumberedAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let annotationView = annotationView as? NumberedAnnotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            
            if let custom = annotation as? ScorePointAnnotation {
                annotationView.scoreLabel.text = String(custom.score)
            }
            
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation {
            if annotation.isKind(of: MKUserLocation.self) {
                print("selected MKUserLocation annotation")
            } else {
                if let optional = annotation.title,
                    let key = optional {
                    print("selected \(key)")
                    showPost(withKey: key)
                    mapView.deselectAnnotation(view.annotation, animated: false)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for var view in views {
            view.canShowCallout = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hidePost()
    }
    
    func updateMapRegion() {
        DispatchQueue.global(qos: .default).async {
            self.viewModel.updateMapRegion(to: self.map.currentMapRegion())
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateMapRegion()
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        updateMapRegion()
    }
}

extension MapViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        showTextEntry(withImage: image)
    }
    
    func showTextEntry(withImage image: UIImage) {
        textEntryView = TextEntryView.instanceFromNib()
        textEntryView?.imageView.image = image
        containerView.contain(view: textEntryView!)
        containerView.animateIn()
        textEntryView?.clipsToBounds = true
        textEntryView?.textField.becomeFirstResponder()
        textEntryView?.textField.delegate = self
    }
}

class MapViewController: AuthenticatedViewController, UINavigationControllerDelegate {
    
    fileprivate let viewModel = ViewModel()
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var map: PulseMap!
    @IBOutlet weak var containerView: UIView!
    
    var textEntryView: TextEntryView?
    var imagePicker: UIImagePickerController!
    
    let annotationIdentifier = "AnnotationIdentifier"
    
    @IBAction func handleAdd(_ sender: Any) {
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.alpha = 0
        createAuthStateListener() // handles authentication state
        
        map.delegate = self
        map.showsUserLocation = true
        map.showsTraffic = true
        map.showsBuildings = true
        map.showsPointsOfInterest = true
        
        viewModel.map = self.map // interface for new posts listener to notify map
        map.user.map = self.map // interface for user tracking to notify map to update
        
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

}

extension MapViewController {
    
    func showPost(withKey key: String) {
        let postView = PostView.instanceFromNib()
        containerView.contain(view: postView)
        postView.clipsToBounds = true
        postView.comment.alpha = 0
        self.containerView.animateIn()
        
        viewModel.getPost(fromKey: key) { (post) in
            postView.comment.text = post.comment
            UIView.animate(withDuration: 0.2, animations: {
                postView.comment.alpha = 1
            })
            postView.imageView.setShowActivityIndicator(true)
            postView.imageView.setIndicatorStyle(.gray)
            postView.imageView.sd_setImage(with: URL(string: post.imageURL))
        }
    }
    
    func hidePost() {
        containerView.animateOut()
    }
    
}


class ViewModel {
    
    let showScoreOnPins = true
    
    let hash = Hash()
    var map: Map?
    
    var firebase: DatabaseReference!
    var postsRef: DatabaseReference!
    var geoPostsRef: DatabaseReference!
    var userPostsRef: DatabaseReference!
    
    var storage = Storage.storage()
    var storageRef: StorageReference!
    var imagesRef: StorageReference!
    
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
    
    func updateMapRegion(to region: MKCoordinateRegion) {
        
        if regionQuery == nil {
            regionQuery = geoFire.query(with: region)
            
            // Create listener for posts entering the screen region
            regionQuery?.observe(.keyEntered, with: { (key, location) in // observer of new post objects in region
                
                self.addPin(key: key!, location: location!)
                
            })
            
            // Create listener for posts leaving the screen region
            regionQuery?.observe(.keyExited, with: { (key, location) in // observer of deletion of post objects in region
                self.map?.removePin(key: key!)
            })
        } else {
            regionQuery?.region = region // update the screen region
        }
    }
    
    func addPin(key: String, location: CLLocation) {
        if showScoreOnPins {
            getPost(fromKey: key, completionHandler: { (post) in
                self.map?.addPin(key: key, location: location, score: post.score)
            })
            
        } else {
            map?.addPin(key: key, location: location, score: 0)
        }
    }
}

//  ViewModel methods that allow the user to create a new post
//
//  - upload images to Firebase Storage
//  - store latitude & longitude of post (GeoPost)
//  - create data post for image and message
//  - create user post for associating user with post
//
extension ViewModel {
    
    func newPost(atLocation coordinate: CLLocationCoordinate2D, withImage image: UIImage, withComment comment: String) {
        
        let key = hash.generate()
        let uid = Auth.auth().currentUser?.uid
        
        var imageData = Data()
        imageData = UIImageJPEGRepresentation(image, 0)!
        
        uploadImage(key: key, data: imageData) { (imageURL) in
            
            self.createPost(key: key, message: comment, imageURL: imageURL, uid: uid!)
            self.createGeoPost(key: key, latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.createUserPost(key: key, uid: uid!)
            
        }
    }
    
    func uploadImage(key: String, data: Data, completionHandler: @escaping (String) -> ()) {
        
        let thisImageRef = self.imagesRef.child(key)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        thisImageRef.putData(data, metadata: metaData) { metadata, error in
            if let error = error {
                print("there was an error uploading the file")
            } else {
                completionHandler(metadata!.downloadURL()!.absoluteString)
            }
        }
    }
    
    func createPost(key: String, message: String, imageURL: String, uid: String) {
        let post = postsRef.child(key)
        post.setValue(["message": message,
                       "timestamp": NSDate().timeIntervalSince1970,
                       "score": 1,
                       "image": imageURL,
                       "user": uid])
    }
    
    func createGeoPost(key: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        geoFire.setLocation(CLLocation(latitude: latitude, longitude: longitude), forKey: key)
    }
    
    func createUserPost(key: String, uid: String) {
        let user = userPostsRef.child(uid)
        let userPost = user.child(key)
        userPost.setValue(["score": 0])
    }
}

class PulseMap: MKMapView, Map {
    
    let user = UserLocation()

    func addPin(key: String, location: CLLocation, score: Int) {
        if !pinExists(withKey: key) {
            
            let coordinate = location.coordinate
            let annotation = ScorePointAnnotation()
            annotation.title = key
            annotation.score = score
            annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.addAnnotation(annotation)
        }
    }
    
    func removePin(key: String) {
        for annotation in self.annotations {
            if let title = annotation.title {
                if title == key {
                    self.removeAnnotation(annotation)
                }
            }
        }
    }
    
    private func pinExists(withKey key: String) -> Bool {
        for pin in self.annotations {
            if let title = pin.title {
                if title == key {
                    return true
                }
            }
        }
        return false
    }
    
    func removeOffscreenPins() {
        DispatchQueue.global(qos: .default).async {
            let visible = self.annotations(in: self.visibleMapRect)
            for annotation in self.annotations {
                if !visible.contains(annotation as! AnyHashable) {
                    self.removeAnnotation(annotation)
                }
            }
        }
    }
    
    func moveToUserLocation() {
        let center = CLLocationCoordinate2D(latitude: (user.currentLatitude()), longitude: (user.currentLongitude()))
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.setRegion(region, animated: true)
    }
    
    func currentMapRegion() -> MKCoordinateRegion {
        return self.region
    }
    
    func currentUserLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: user.currentLatitude(), longitude: user.currentLongitude())
    }
}

class UserLocation: NSObject, CLLocationManagerDelegate {
    
    var map: Map?
    var launchLocationSet = false
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation = CLLocation()
    
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last! as CLLocation!
        if !launchLocationSet {
            map?.moveToUserLocation()
            launchLocationSet = true
        }
    }
    
    func currentLatitude() -> CLLocationDegrees {
        return currentLocation.coordinate.latitude
    }
    
    func currentLongitude() -> CLLocationDegrees {
        return currentLocation.coordinate.longitude
    }
}


struct Post {
    var comment: String
    var imageURL: String
    var score: Int
}

protocol Map : class {
    func addPin(key: String, location: CLLocation, score: Int)
    func removePin(key: String)
    func moveToUserLocation()
}
