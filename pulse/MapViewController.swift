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

class MapViewController: UIViewController, UINavigationControllerDelegate, MKMapViewDelegate {
    
    var textEntryView: TextEntryView?
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var mapView: PulseMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var resultsButton: UIView!
    @IBOutlet weak var resultsCountLabel: UILabel!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var resultsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pastTwentyFourLabel: UILabel!
    
    @IBAction func cameraButtonTouchUpInside(_ sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createResultsButton()
        mapView.delegate = self
        mapView.showsUserLocation = false
        mapView.isRotateEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addPost(_:)), name: NSNotification.Name(rawValue: "addPost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removePost(_:)), name: NSNotification.Name(rawValue: "removePost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hidePost(_:)), name: NSNotification.Name(rawValue: "hidePost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateLocation(_:)), name: NSNotification.Name(rawValue: "updateLocation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateScore(_:)), name: NSNotification.Name(rawValue: "updateScore"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "addPost"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "removePost"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "hidePost"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateLocation"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateScore"), object: nil)
    }
    
    func addPost(_ notification: NSNotification) {
        setResultsCount()
        if let key = notification.userInfo?["key"] as? String,
            let location = notification.userInfo?["location"] as? CLLocation {
            
            mapView.addPin(key: key, location: location)
        }
    }
    
    func removePost(_ notification: NSNotification) {
        setResultsCount()
        if let key = notification.userInfo?["key"] as? String {
            
            mapView.removePin(key: key)
        }
    }
    
    func hidePost(_ notification: NSNotification) {
        hidePost()
    }
    
    func updateLocation(_ notification: NSNotification) {
        if mapView != nil {
            mapView.moveTo(location: userLocation!.currentLocation)
        }
    }
    
    func updateScore(_ notification: NSNotification) {
        accountLabel.text = String(accountModel!.score)
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
                    
                }
            }
        }
    }
    
    @objc func showAllPosts(_ sender: UITapGestureRecognizer) {
        showPost(for: nil)
    }
    
    func showPost(for key: String?) {
        
        guard firebase.posts.count > 0 else { return }
        
        var frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: scrollView.frame.width,
                                   height: scrollView.frame.height)
        
        func createPostView(for viewModel: PostViewModel) {
            let postView = PostView.instanceFromNib()
            
            postView.viewModel = viewModel
            postView.viewModel.delegate = postView
            postView.updateUI()
            postView.clipsToBounds = true
            postView.frame = frame
            
            frame.origin.x = frame.origin.x + frame.width
            
            scrollView.addSubview(postView)
        }
        
        if let key = key,
            let first = firebase.posts[key] {
            createPostView(for: first)
        }
        
        for (this, viewModel) in firebase.posts {
            if this != key {
                createPostView(for: viewModel)
            }
        }
        
        let content = CGRect(x: 0, y: 0,
                             width: scrollView.frame.width * CGFloat(firebase.posts.count),
                             height: scrollView.frame.height)
        
        scrollView.contentSize = content.size
        scrollView.scrollTo(direction: .left, animated: false)
        scrollView.isHidden = false
  
    }
    
    func hidePost() {

        scrollView.isHidden = true
        
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        firebase.update(mapRegion: mapView.region)
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if fullyRendered {
            UIView.animate(withDuration: 0.2, animations: {
                self.loadingView.alpha = 0
            }) { (true) in
                self.loadingView.isHidden = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        firebase.update(mapRegion: mapView.region)
        setResultsCount()
        showHideResultsViews(isMoving: false)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        setResultsCount()
        showHideResultsViews(isMoving: true)
    }
    
    func createResultsButton() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAllPosts(_:)))
        resultsButton.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func showHideResultsViews(isMoving: Bool) {
        resultsActivityIndicator.isHidden = !isMoving
        resultsLabel.isHidden = isMoving
        resultsCountLabel.isHidden = isMoving
        pastTwentyFourLabel.isHidden = isMoving
    }
    
    func setResultsCount() {
        resultsCountLabel.text = String(firebase.posts.count)
        
        if firebase.posts.count != 0 {
            pastTwentyFourLabel.text = "from the past 24 hours"
        } else {
            pastTwentyFourLabel.text = "try moving the map"
        }
    }
    
}
