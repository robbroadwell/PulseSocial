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
    
    let viewModel = ViewModel()
    
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
