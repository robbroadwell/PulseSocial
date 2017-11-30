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
import SDWebImage

class MapViewController: AuthenticatedViewController, UINavigationControllerDelegate, MKMapViewDelegate {
    
    let annotationIdentifier = "AnnotationIdentifier"
    
    let viewModel = ViewModel()
    
    @IBOutlet weak var map: PulseMap!
    @IBOutlet weak var containerView: UIView!
    
    var textEntryView: TextEntryView?
    var imagePicker: UIImagePickerController!
    
    @IBAction func handleAdd(_ sender: Any) {
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.alpha = 0
        createAuthStateListener()
        
        map.delegate = self
        map.showsUserLocation = true
        map.showsTraffic = true
        map.showsBuildings = true
        map.showsPointsOfInterest = true
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
        
        let annotationView = NumberedAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        annotationView.canShowCallout = true
        
        if let custom = annotation as? ScorePointAnnotation {
            annotationView.scoreLabel.text = String(custom.score)
        }
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation {
            if !annotation.isKind(of: MKUserLocation.self) {
                if let optional = annotation.title,
                    let key = optional {
                    showPost(withKey: key)
                    mapView.deselectAnnotation(view.annotation, animated: false)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            view.canShowCallout = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hidePost()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        viewModel.updateMapRegion(to: map.currentMapRegion())
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        viewModel.updateMapRegion(to: map.currentMapRegion())
    }
    
}
