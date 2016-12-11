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
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cameraTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func storageTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func postTapped(_ sender: UIButton) {
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.6)
        let compressedJPEGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPEGImage!, nil, nil, nil)
        saveNotice()
    }
    
    func saveNotice() {
        let alertController = UIAlertController(title: "Image Saved", message: "Your picture was successfully saved.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: UINavigationControllerDelegate

extension CameraViewController: UINavigationControllerDelegate {
    
}

// MARK: UIImagePickerControllerDelegate

extension CameraViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
}

// MARK: AVCapturePhotoCaptureDelegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput, didCapturePhotoForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
        //        self.capturedImageView.image = capture
    }
}
