//
//  CameraViewController.swift
//  pictures
//
//  Created by Andrew Carvajal on 12/11/16.
//  Copyright © 2016 YugeTech. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseStorage

class CameraViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var flashView: UIView!
    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    var session: AVCaptureSession?
    var cameraOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataSource.si.cameraState = .takingPhoto
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
        
        if DataSource.si.cameraState == .takingPhoto {
            
            captureImageView.center = view.center
            
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
            
        // camera state is .tookPhoto
        } else {
            
            // hide the capture image view and progress view
            captureImageView.isHidden = true
            progressView.isHidden = true
            
            DataSource.si.cameraState = .takingPhoto
        }
    }
    
    @IBAction func panFired(_ sender: UIPanGestureRecognizer) {
        
        if DataSource.si.cameraState == .tookPhoto {
            
            // if pan inside captureImageView
            if captureImageView.frame.contains(sender.location(in: captureImageView)) {
                
                // if pan is going up
                if sender.translation(in: view).y < 0 {
                    
                    // slide capture image view up
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.5, initialSpringVelocity: 1.5, options: .curveEaseIn, animations: { 
                        
                        self.captureImageView.frame = CGRect(x: 0, y: self.view.frame.minY - self.captureImageView.frame.height - 50, width: self.captureImageView.frame.width , height: self.captureImageView.frame.height)
                    }, completion: { finished in
                        
                        DataSource.si.cameraState = .takingPhoto
                        
                        self.sharePhoto()
                    })
                }
            }
        }
    }
    
    func sharePhoto() {
        
        // show progress view
        progressView.isHidden = false

        // get date
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy_hh:mm:ss_a"
        let dateResult = formatter.string(from: date)
        
        // save photo to firebase with date
        let storageRef = FIRStorage.storage().reference(withPath: "pictures/\(dateResult).jpg")
        let uploadMetadata = FIRStorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        let uploadTask = storageRef.put(DataSource.si.lastTakenPhotoData as! Data, metadata: uploadMetadata) { (metadata, error) in
            if error != nil {
                print("error saving to firebase: \(error?.localizedDescription)")
            } else {
                print("upload to firebase complete: \(metadata)")
                print("download URL: \(metadata?.downloadURL())")
                
                // hide progress view
                self.progressView.isHidden = true
            }
        }
        uploadTask.observe(.progress) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            guard let progress = snapshot.progress else { return }
            strongSelf.progressView.progress = Float(progress.fractionCompleted)
        }
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
            
            // set the capture image view to the processed image data
            captureImageView.image = UIImage(data: dataImage)
            
            // store the last taken photo data to be stored in firebase
            DataSource.si.lastTakenPhotoData = dataImage as NSData?
            
            DataSource.si.cameraState = .tookPhoto
            
            // show capture image view
            captureImageView.isHidden = false
        }
    }
}
