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

class MapViewController: UIViewController, UINavigationControllerDelegate, MKMapViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var mapView: PulseMapView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var headerCloseButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var cameraButton: UIImageView!
    @IBOutlet weak var cameraCloseButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var cameraPreviewImage: UIImageView!
    @IBOutlet weak var pulseButton: UIImageView!
    @IBOutlet weak var postsButton: UIView!
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateScore(_:)), name: NSNotification.Name(rawValue: "updateScore"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "addPost"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "removePost"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "hidePost"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateLocation"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateScore"), object: nil)
    }
    
    // MARK: - MAP MOVEMENT
    
    func addPost(_ notification: NSNotification) {
        if let key = notification.userInfo?["key"] as? String,
            let location = notification.userInfo?["location"] as? CLLocation {
            
            mapView.addPin(key: key, location: location)
            countLabel.text = "\(firebase.posts.count)"
        }
    }
    
    func removePost(_ notification: NSNotification) {
        if let key = notification.userInfo?["key"] as? String {
            
            mapView.removePin(key: key)
            countLabel.text = "\(firebase.posts.count)"
        }
    }
    
    func updateLocation(_ notification: NSNotification) {
        if mapView != nil {
            mapView.moveTo(location: userLocation!.currentLocation)
        }
    }
    
    func updateScore(_ notification: NSNotification) {
//        scoreLabel.text = String(accountModel!.score)
    }
    
    // MARK: - SHOW POST
    
    @objc func showAllPosts(_ sender: UITapGestureRecognizer) {
        showPost(for: nil)
    }
    
    func showSinglePost(key: String, image: UIImage) {
        let frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: scrollView.frame.width,
                                   height: scrollView.frame.height)

        let postView = PostView.instanceFromNib()
        
        postView.viewModel = PostViewModel(key: key)
        postView.viewModel.image = image
        postView.viewModel.delegate = postView
        postView.updateUI()
        postView.clipsToBounds = true
        postView.frame = frame
            
        scrollView.addSubview(postView)
        
        let content = CGRect(x: 0, y: 0,
                             width: scrollView.frame.width,
                             height: scrollView.frame.height)
        
        scrollView.contentSize = content.size
        scrollView.scrollTo(direction: .left, animated: false)
        scrollView.isHidden = false
        mapView.alpha = 0
        
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

        mapView.alpha = 0
    }
    
    func hidePost(_ notification: NSNotification) {
        hidePost()
    }
    
    func hidePost() {

        scrollView.isHidden = true
        countLabel.text = "\(firebase.posts.count)"
        mapView.alpha = 1
        
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let page = Int(round(scrollView.contentOffset.x/scrollView.frame.width))
//        countLabel.text = "\(page + 1) of \(firebase.posts.count)"
//    }
    
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
        countLabel.text = "\(firebase.posts.count)"
        firebase.update(mapRegion: mapView.region)
        activityIndicator.isHidden = true
        countLabel.isHidden = false
        postsLabel.isHidden = false
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        countLabel.text = "\(firebase.posts.count)"
        activityIndicator.isHidden = false
        countLabel.isHidden = true
        postsLabel.isHidden = true
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
    
    // MARK: - CAMERA
    
    func createCustomButtons() {
        let pulseTap = UITapGestureRecognizer(target: self, action: #selector(pulseButtonTouchUpInside))
        pulseButton.addGestureRecognizer(pulseTap)
        pulseButton.isUserInteractionEnabled = true
        
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsButtonTouchUpInside))
        postsButton.addGestureRecognizer(postsTap)
        postsButton.isUserInteractionEnabled = true
        
        let cameraTap = UITapGestureRecognizer(target: self, action: #selector(cameraButtonTouchUpInside))
        cameraButton.addGestureRecognizer(cameraTap)
        cameraButton.isUserInteractionEnabled = true
    
    }
    
    func pulseButtonTouchUpInside() {
        settingsView.isHidden = false
        headerCloseButton.isHidden = false
        postsLabel.isHidden = true
        countLabel.isHidden = true
    }
    
    func postsButtonTouchUpInside() {
        if settingsView.isHidden {
            showPost(for: nil)
        } else {
            settingsView.isHidden = true
            headerCloseButton.isHidden = true
            postsLabel.isHidden = false
            countLabel.isHidden = false
        }
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
        firebase.newPost(atLocation: (userLocation?.currentLocation.coordinate)!, withImage: cameraPreviewImage.image!, withComment: "") { (key) in
            
            self.cameraView.isHidden = true
            self.cameraCloseButton.isHidden = true
            self.cameraPreview.isHidden = true
            self.showSinglePost(key: key, image: self.cameraPreviewImage.image!)
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
