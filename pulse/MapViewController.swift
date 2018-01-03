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
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cameraButton: UIImageView!
    @IBOutlet weak var cameraCloseButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var cameraPreviewImage: UIImageView!
    
    var captureSession: AVCaptureSession?
    var cameraOutput = AVCapturePhotoOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCustomButtons()
        scrollView.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateScore"), object: nil)
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
    
    @objc func showAllPosts(_ sender: UITapGestureRecognizer) {
        showPost(key: nil)
    }
    
    func createPostView(withFrame frame: CGRect, andViewModel viewModel: PostViewModel) {
        let postView = PostView.instanceFromNib()
        
        postView.viewModel = viewModel
        postView.viewModel.delegate = postView
        postView.updateUI()
        postView.clipsToBounds = true
        postView.frame = frame
        
        scrollView.addSubview(postView)
    }
    
    func showSinglePost(key: String, image: UIImage) {
        let frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: scrollView.frame.width,
                                   height: scrollView.frame.height)
        
        createPostView(withFrame: frame, andViewModel: PostViewModel(key: key))
        
        scrollView.contentSize = frame.size
        scrollView.scrollTo(direction: .left, animated: false)
        scrollView.isHidden = false
        mapView.alpha = 0
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
