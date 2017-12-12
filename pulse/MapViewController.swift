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
    
    var isShowingPost = false
    
//    var cardOriginalCenter: CGPoint!
//    var cardDownOffset: CGFloat!
//    var cardUp: CGPoint!
//    var cardDown: CGPoint!
    
    let firebase = Firebase()
    
    var textEntryView: TextEntryView?
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var map: PulseMap!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    
//    @IBAction func favoriteButtonTouchUpInside(_ sender: UIButton) {
//        print("favorite")
//    }
    
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
//        createPanGestureRecognizer()
//        setCardConstants()
        
        map.delegate = self
        map.showsUserLocation = false
    }
    
//    func setCardConstants() {
//        cardDownOffset = 120
//        cardUp = cardView.center
//        cardDown = CGPoint(x: cardView.center.x, y: cardView.center.y + cardDownOffset)
//    }
//
//    func createPanGestureRecognizer() {
//        let selector = #selector(didPan(_:))
//        let pan = UIPanGestureRecognizer(target: self, action: selector)
//        cardView.addGestureRecognizer(pan)
//    }
    
//    func didPan(_ sender: UIPanGestureRecognizer) {
//        let translation = sender.translation(in: view)
//        print("translation \(translation)")
//
//        if sender.state == UIGestureRecognizerState.began {
//            cardOriginalCenter = cardView.center
//        } else if sender.state == UIGestureRecognizerState.changed {
//            cardView.center = CGPoint(x: cardOriginalCenter.x, y: cardOriginalCenter.y + translation.y)
//        } else if sender.state == UIGestureRecognizerState.ended {
//            if sender.velocity(in: self.view).y > 0 {
//                UIView.animate(withDuration: 0.3, animations: { () -> Void in
//                    self.cardView.center = self.cardDown
//                })
//            } else {
//                UIView.animate(withDuration: 0.3, animations: { () -> Void in
//                    self.cardView.center = self.cardUp
//                })
//            }
//        }
//    }

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
            let location = notification.userInfo?["location"] as? CLLocation,
            let post = notification.userInfo?["post"] as? Post {

            map.addPin(key: key, location: location, post: post)
        }
    }
    
    func removePost(_ notification: NSNotification) {
        if let key = notification.userInfo?["key"] as? String {
            map.removePin(key: key)
        }
    }
    
    func showPost(_ sender: UITapGestureRecognizer) {
        print(sender)
    }
    
    func updateLocation(_ notification: NSNotification) {            
        map.moveToUserLocation()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationView = NumberedAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationIdentifier")
        annotationView.canShowCallout = true

        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation {
            if !annotation.isKind(of: MKUserLocation.self) {
                if let custom = annotation as? MKPostAnnotation,
                    let post = custom.post {
                    show(post)
                    mapView.deselectAnnotation(view.annotation, animated: false)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isShowingPost {
            hidePost()
            isShowingPost = false
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        firebase.updateMapRegion(to: map.currentMapRegion())
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        firebase.updateMapRegion(to: map.currentMapRegion())
    }
    
}
