//
//  ViewController.swift
//  FacialRec
//
//  Created by Jonathan Lu on 3/30/17.
//  Copyright © 2017 Jonathan Lu. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    
    let session = AVCaptureSession()
    var frontCamera: AVCaptureDevice!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        findFrontCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func capture(_ sender: AnyObject) throws {
        
        let frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
        
        if self.session.canAddInput(frontCameraInput) {
            self.session.addInput(frontCameraInput)
        }
 
        let videoOutput = AVCaptureVideoDataOutput()
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        let stillCameraOutput = AVCapturePhotoOutput()
        if self.session.canAddOutput(stillCameraOutput) {
            self.session.addOutput(stillCameraOutput)
        }
        
        let sessionQueue = DispatchQueue(label: "session")
        sessionQueue.async { () -> Void in
            self.session.startRunning()
        }
        
        
        sessionQueue.async { () -> Void in
            
            let connection = stillCameraOutput.connection(withMediaType: AVMediaTypeVideo)
            
            // update the video orientation to the device one
            connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
            
            stillCameraOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            captureStillImageAsynchronouslyFromConnection(connection) {
                (imageDataSampleBuffer, error) -> Void in
                
                if error == nil {
                    
                    // if the session preset .Photo is used, or if explicitly set in the device's outputSettings
                    // we get the data already compressed as JPEG
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    
                    // the sample buffer also contains the metadata, in case we want to modify it
                    let metadata:NSDictionary = CMCopyDictionaryOfAttachments(nil, imageDataSampleBuffer, CMAttachmentMode(kCMAttachmentMode_ShouldPropagate)).takeUnretainedValue()
                    
                    if let image = UIImage(data: imageData) {
                        // save the image or do something interesting with it
                        
                    }
                }
                else {
                    NSLog("error while capturing still image: \(error)")
                }
            }
        }
        
    }
    
    private func findFrontCamera() {
        let availableCameraDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for device in availableCameraDevices as! [AVCaptureDevice] {
            if device.position == .front {
                frontCamera = device
            }
        }
    }
    
}

