//
//  MapViewController.swift
//  pulse
//
//  Created by Rob Broadwell on 5/23/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

class MapViewController: AuthenticatedViewController, UINavigationControllerDelegate, MKMapViewDelegate {
    
    let firebase = Firebase()
    var textEntryView: TextEntryView?
    var imagePicker: UIImagePickerController!
    var isShowingPost = false
    
    @IBOutlet weak var map: PulseMap!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    
    @IBAction func cameraButtonTouchUpInside(_ sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAuthStateListener()
        containerViewTopConstraint.constant = screenHeight
        containerViewHeightConstraint.constant = screenHeight
        
        map.delegate = self
        map.showsUserLocation = false
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addPost(_:)), name: NSNotification.Name(rawValue: "addPost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removePost(_:)), name: NSNotification.Name(rawValue: "removePost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateLocation(_:)), name: NSNotification.Name(rawValue: "updateLocation"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "addPost"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "removePost"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateLocation"), object: nil)
    }
    
    func addPost(_ notification: NSNotification) {
        if let key = notification.userInfo?["key"] as? String,
            let location = notification.userInfo?["location"] as? CLLocation {
            
            map.addPin(key: key, location: location)
        }
    }
    
    func removePost(_ notification: NSNotification) {
        if let key = notification.userInfo?["key"] as? String {
            map.removePin(key: key)
        }
    }
    
    func updateLocation(_ notification: NSNotification) {            
        map.moveToUserLocation()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationView = MKPostAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationIdentifier")
        annotationView.canShowCallout = true

        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation {
            mapView.deselectAnnotation(annotation, animated: false)
            
            if !annotation.isKind(of: MKUserLocation.self) {
                if let custom = annotation as? MKPointAnnotation,
                    let key = custom.title {
                    
                    showPost(for: key)
                    isShowingPost = true
                    
                }
            }
        }
    }
    
    func showPost(for key: String) {
        
        let postView = PostView.instanceFromNib()
        postView.viewModel = firebase.posts[key]
        postView.viewModel.delegate = postView
        
        postView.updateUI()
        postView.clipsToBounds = true
        postView.imageView.setShowActivityIndicator(true)
        
        containerView.contain(view: postView)
        containerViewTopConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hidePost() {
        containerViewTopConstraint.constant = screenHeight
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isShowingPost {
            hidePost()
            isShowingPost = false
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        firebase.update(mapRegion: map.currentMapRegion())
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        firebase.update(mapRegion: map.currentMapRegion())
    }
    
}
