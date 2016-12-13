//
//  CameraViewController.swift
//  pictures
//
//  Created by Andrew Carvajal on 12/11/16.
//  Copyright © 2016 YugeTech. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var flashView: UIView!
    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    var session: AVCaptureSession?
    var cameraOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // create session
        session = AVCaptureSession()
        
        // create back camera input
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        // add the input to the session
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            
            // create output
            cameraOutput = AVCapturePhotoOutput()
            
            // set it to the preview view
            if session!.canAddOutput(cameraOutput) {
                session!.addOutput(cameraOutput)
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                previewView.layer.addSublayer(videoPreviewLayer!)
                session!.startRunning()
                videoPreviewLayer!.frame = previewView.bounds
            }
        }
    }
    
    @IBAction func tapFired(_ sender: UITapGestureRecognizer) {
        
        // configure photo settings
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        settings.isAutoStillImageStabilizationEnabled = true
        
        // capture photo
        cameraOutput?.capturePhoto(with: settings, delegate: self)
        
        flashEffectFullScreen()
    }
    
    @IBAction func cancalButtonTapped(_ sender: UIButton) {
        
        captureImageView.isHidden = true
        cancelButton.isHidden = true
    }
    
    private func flashEffectFullScreen() {
        
        // set flash view to white
        flashView.backgroundColor = UIColor.white
        
        // animate it back to clear
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
            self.flashView.backgroundColor = UIColor.clear
        }) { finished in
        }
    }
}

// MARK: UINavigationControllerDelegate

extension CameraViewController: UINavigationControllerDelegate {}

// MARK: UIImagePickerControllerDelegate

extension CameraViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {}
}

// MARK: AVCapturePhotoCaptureDelegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        // set the processed photo to the capture image view
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            
            captureImageView.isHidden = false
            cancelButton.isHidden = false
            captureImageView.image = UIImage(data: dataImage)
        }
    }
}
