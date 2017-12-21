//
//  CameraViewController.swift
//  pulse
//
//  Created by Rob Broadwell on 12/20/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraButton: UIImageView!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var cameraPreviewImage: UIImageView!
    
    var captureSession: AVCaptureSession?
    var cameraOutput = AVCapturePhotoOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        setupCamera()
        createCustomButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - CAMERA
    
    func createCustomButtons() {
        
        let cameraTap = UITapGestureRecognizer(target: self, action: #selector(cameraButtonTouchUpInside))
        cameraButton.addGestureRecognizer(cameraTap)
        cameraButton.isUserInteractionEnabled = true
        
    }
    
    func cameraButtonTouchUpInside() {
        snapPhoto()
    }
    
    @IBAction func cameraCloseButtonTouchUpInside(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "returnToPreviousTab"), object: nil, userInfo: nil)
    }

    @IBAction func previewCloseTouchUpInside(_ sender: UIButton) {
        cameraPreview.isHidden = true
    }

    @IBAction func previewSendTouchUpInside(_ sender: UIButton) {
        firebase.newPost(atLocation: userLocation.currentLocation.coordinate, withImage: cameraPreviewImage.image!, withComment: "") { (key) in
            
            self.cameraPreview.isHidden = true
            let dict: [String : Any] = ["key": key, "location": userLocation.currentLocation]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "moveToUserPost"), object: nil, userInfo: dict)

        }
    }
    
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
