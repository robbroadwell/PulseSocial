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
import AVFoundation
import Firebase

class MapViewController: UIViewController, UINavigationControllerDelegate, MKMapViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var mapView: PulseMapView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cameraButton: UIImageView!
    @IBOutlet weak var cameraCloseButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var cameraPreviewImage: UIImageView!
    @IBOutlet weak var accountDarkView: UIView!
    @IBOutlet weak var accountContentView: UIView!
    @IBOutlet weak var accountContentViewBottomContraint: NSLayoutConstraint!
    
    var captureSession: AVCaptureSession?
    var cameraOutput = AVCapturePhotoOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCustomButtons()
        scrollView.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = false
        mapView.isRotateEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.addPost(_:)), name: NSNotification.Name(rawValue: "addPost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removePost(_:)), name: NSNotification.Name(rawValue: "removePost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hidePost(_:)), name: NSNotification.Name(rawValue: "hidePost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateLocation(_:)), name: NSNotification.Name(rawValue: "updateLocation"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "addPost"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "removePost"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "hidePost"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateLocation"), object: nil)
    }
    
    // MARK: - BUTTONS
    
    @IBAction func accountButtonPressed(_ sender: UIButton) {
        if accountDarkView.isHidden {
            accountDarkView.isHidden = false
            accountContentViewBottomContraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.accountDarkView.alpha = 1
                self.view.layoutIfNeeded()
            })
        } else {
            accountContentViewBottomContraint.constant = -225
            UIView.animate(withDuration: 0.3, animations: {
                self.accountDarkView.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                self.accountDarkView.isHidden = true
            })
        }
    }
    
    @IBAction func nearButtonPressed(_ sender: UIButton) {
        mapView.showsUserLocation = true
        mapView.moveTo(location: userLocation!.currentLocation)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.mapView.showsUserLocation = false
        }
    }
    
    @IBAction func reportProblemPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Problem", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        accountButtonPressed(UIButton())
    }
    
    // MARK: - MAP MOVEMENT
    
    func addPost(_ notification: NSNotification) {
        if let key = notification.userInfo?["key"] as? String,
            let location = notification.userInfo?["location"] as? CLLocation {
            
            // a new post entered the map region
            mapView.addPin(key: key, location: location)
            
        }
    }
    
    func removePost(_ notification: NSNotification) {
        if let key = notification.userInfo?["key"] as? String {
            
            // a post left the map region
            mapView.removePin(key: key)
            
        }
    }
    
    func updateLocation(_ notification: NSNotification) {
        if mapView != nil {
            
            // move the map to the user location
            mapView.moveTo(location: userLocation!.currentLocation)
        }
    }
    
    // MARK: - SHOW POST
    
    func createPostView(withFrame frame: CGRect, andViewModel viewModel: PostViewModel) {
        let postView = PostView.instanceFromNib()
        
        postView.viewModel = viewModel
        postView.viewModel.delegate = postView
        postView.updateUI()
        postView.clipsToBounds = true
        postView.frame = frame
        
        scrollView.addSubview(postView)
    }
    
    func showNewPost(key: String, image: UIImage, time: Double) {

        let frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: scrollView.frame.width,
                                   height: scrollView.frame.height)
        
        createPostView(withFrame: frame, andViewModel: PostViewModel(key: key, image: image, score: 1, time: time))
        
        scrollView.contentSize = frame.size
        scrollView.scrollTo(direction: .left, animated: false)
        scrollView.isHidden = false
        mapView.isHidden = true
        
        cameraView.isHidden = true
        cameraCloseButton.isHidden = true
        cameraPreview.isHidden = true
        
    }
    
    func showPost(key: String?) {
        
        guard firebase.posts.count > 0 else { return }
        
        var frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: scrollView.frame.width,
                                   height: scrollView.frame.height)
        
        if let key = key,
            let first = firebase.posts[key] {
            
            createPostView(withFrame: frame, andViewModel: first)
            frame.origin.x = frame.origin.x + frame.width
            
        }
        
//        for (this, viewModel) in firebase.posts {
//            if this != key {
//
//                createPostView(withFrame: frame, andViewModel: viewModel)
//                frame.origin.x = frame.origin.x + frame.width
//
//            }
//        }
        
        let content = CGRect(x: 0, y: 0,
//                             width: scrollView.frame.width * CGFloat(firebase.posts.count),
                             width: scrollView.frame.width,
                             height: scrollView.frame.height)
        
        scrollView.contentSize = content.size
        scrollView.scrollTo(direction: .left, animated: false)
        scrollView.isHidden = false
        mapView.isHidden = true
    }
    
    func hidePost(_ notification: NSNotification) {
        hidePost()
        
        if let message = notification.userInfo?["message"] as? String,
            let title = notification.userInfo?["title"] as? String {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Okay", style: .cancel)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func hidePost() {

        scrollView.isHidden = true
        mapView.isHidden = false
        
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    // MARK: - MAP DELEGATE
    
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
                    
                    showPost(key: key)
                    
                }
            }
        }
    }
    
    // MARK: - CAMERA
    
    func createCustomButtons() {
        
        let cameraTap = UITapGestureRecognizer(target: self, action: #selector(cameraButtonTouchUpInside))
        cameraButton.addGestureRecognizer(cameraTap)
        cameraButton.isUserInteractionEnabled = true
    
    }
    
    func cameraButtonTouchUpInside() {
        
        if !cameraView.isHidden {
            snapPhoto()
            
        } else {
            setupCamera()
            cameraView.isHidden = false
            cameraCloseButton.isHidden = false
        }
    }
    @IBAction func cameraCloseButtonTouchUpInside(_ sender: UIButton) {
        cameraView.isHidden = true
        cameraCloseButton.isHidden = true
    }
    
    @IBAction func previewCloseTouchUpInside(_ sender: UIButton) {
        cameraPreview.isHidden = true
    }
    
    @IBAction func previewSendTouchUpInside(_ sender: UIButton) {
        
        if let location = userLocation?.currentLocation {
            
            let key = Hash.generate()
            let time = NSDate().timeIntervalSince1970
            
            mapView.moveTo(location: location, animated: false, spanDelta: 0.01)
            showNewPost(key: key, image: cameraPreviewImage.image!, time: time)
            firebase.newPost(key: key,
                             coordinate: location.coordinate,
                             image: cameraPreviewImage.image!,
                             comment: "",
                             time: time)
        }
    }
}

extension MapViewController: AVCapturePhotoCaptureDelegate {
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            if let image = UIImage(data: dataImage) {
                cameraPreview.isHidden = false
                cameraPreviewImage.image = image
            }

        }
        
    }
    
    func snapPhoto() {
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        self.cameraOutput.capturePhoto(with: settings, delegate: self)
    
    }

    func setupCamera() {
        
        if captureSession == nil {
            let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession = AVCaptureSession()
                captureSession?.addInput(input)
                captureSession?.addOutput(cameraOutput)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                videoPreviewLayer?.frame = view.layer.bounds
                cameraView.layer.addSublayer(videoPreviewLayer!)
                captureSession?.startRunning()
                
            } catch {
                print(error)
            }
        }
    }
}
