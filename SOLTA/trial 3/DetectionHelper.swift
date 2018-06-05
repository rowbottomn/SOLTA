//
//  Imaging.swift
//  C
//
//  Created by Nathan Rowbottom on 2018-05-29.
//  Copyright © 2018 Guest User. All rights reserved.
//

import Foundation
import UIKit
import GLKit
import AVFoundation
import CoreMotion
import CoreGraphics
import PhotosUI


enum DetectionModes {
    case YUV420v
    case BGRA
}

enum OperationState {
    case TESTING
    case CALIBRATION
    case RUNNING
    case DORMANT
    case OTHER
}

class DetectionHelper{
 
    
    //Singleton class to frontload burden or setupview
    
    static let helper = DetectionHelper()

     var viewController = DetectionVC()
  //   var cameraView = GLKView()
     var imageView = UIImageView()
    
    //this is an image which we start with when we start detecting, also allows us to start other objects.
    static var lastImage = UIImage(named: "2ndpage.png")
    lazy var cgimage = DetectionHelper.lastImage?.cgImage!
    lazy var ciimage = CIImage(cgImage: cgimage!)

    static var cgcontext = UIGraphicsGetCurrentContext()!

    //make the queue for the frames
    let imageQueue = DispatchQueue(label:"ca.hdsb.solta.queue")

    //MARK: glContext object construction
    lazy var glContext: EAGLContext = {
        let glContext = EAGLContext(api: .openGLES3)
        return glContext!
    }()
    
    //GLKView is used for views that use OpenGL ES
    //testing
    lazy var glView: GLKView = {
        let glView = GLKView(frame: CGRect(x: 0, y: 0, width: self.imageView.frame.width, height: self.imageView.frame.height), context: self.glContext)
        glView.bindDrawable() //bind the glView to the OpenGl instance.
        
        return glView
    }()
    
    //CIContext is used for image processing
    lazy var ciContext: CIContext = {
        let ciContext = CIContext(eaglContext: self.glContext)
        return ciContext
    }()
    
    let motionManager = CMMotionManager()
    
    var timer = Timer();
    
    
    //MARK: Variables
    var droppedFrames = 0
    var numFrames = 0
    var numEvents = 0
    var accData = (x: 0.0, y: 0.0, z:-1.0)
    var isFlat: Bool = false
    var timeStarted = CFAbsoluteTimeGetCurrent()
    var timeElapsed = CFAbsoluteTimeGetCurrent()
    var flux : Double = 0
    let targetFlux = 1.0/10.0;
    let detectionMode = DetectionModes.YUV420v
    var pixelsToSkip : Int = 2
    //moved this to the outside
 //   var scale = UIScreen.main.scale
  //  var newFrame = CGRect(x: 0, y: 0, width: 100, height:100 )//this should be overrode to the frame of the imageview
    var intensityThreshholds = [
        (DetectionModes.BGRA, CGFloat(450.0)),
        (DetectionModes.YUV420v, CGFloat(160))//remember this is logarithmic scale
    ]
    var minRaySize = 1// pixelsToSkip;//numberof pixels that represents how many pizels should be in an image
    var currentState: OperationState = OperationState.RUNNING;
    
    
    
    //MARK: capturesession
    lazy var cameraSession: AVCaptureSession = {
        let session = AVCaptureSession()
        //testing difference between the two modes
        session.sessionPreset = AVCaptureSession.Preset.high
        //session.sessionPreset = AVCaptureSession.Preset.low
        
        return session
    }()
    
    func setupCameraSession(){
 
        //get the camera device, making sure its the rear facing; NOTe that the wideangle seems to be the general purpose
        let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            
            cameraSession.beginConfiguration()//is this harmful in that it will not be condusive to getting rays?
            
            //if we can, lets get that input from the camera
            if (cameraSession.canAddInput(deviceInput)){
                cameraSession.addInput(deviceInput)
            }
            
            //output handling
            
            let dataOutput = AVCaptureVideoDataOutput()
 
            var mostValidPixelType =  dataOutput.availableVideoPixelFormatTypes[0]

            
            switch detectionMode {
            case .BGRA:
                mostValidPixelType = dataOutput.availableVideoPixelFormatTypes[2]
                break
            case .YUV420v:
                mostValidPixelType = dataOutput.availableVideoPixelFormatTypes[0]
                break
            }
            
            //print("Pixel Type: \(mostValidPixelType)")
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value: mostValidPixelType)] as [String : Any] //kCVPixelFormatType_32RGBA <== it really wants a string
            dataOutput.alwaysDiscardsLateVideoFrames = true //May have to relax this...
            
            if cameraSession.canAddOutput(dataOutput){
                cameraSession.addOutput(dataOutput)
            }
            
            cameraSession.commitConfiguration()//configuration was successful if we got here so commit it
            
            dataOutput.setSampleBufferDelegate(viewController,  queue: imageQueue)
            
        } catch let error as NSError{
            NSLog("\(error), \(error.localizedDescription)")
            
        }
    }
    
    //the width and height appear to be the same dimensions, the big difference is the numpixelsperrow
    var planeWidth : Int = 0
    var planeHeight : Int = 0
    
    var bytesPerRow : Int = 0
    var bytesPerRowofPlane : Int = 0
    
    var width : Int = 0
    var height : Int = 0
    
    var w = CGFloat(0)
    var h = CGFloat(0)
    var intensityThreshhold : CGFloat = 0
    
    //MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func capturedOutput( sampleBuffer: CMSampleBuffer ) {
        
       // if !isFlat{
        //    currentState = .DORMANT
      //  }
     //   else{
            currentState = .RUNNING
   //     }
        
        numFrames += 1
        
        switch (currentState){
            
            
        case .RUNNING, .CALIBRATION, .OTHER, .TESTING:
           // print("Frames + \(numFrames)")
            //lets get those frame
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            
            //lock that buffer down
            CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            let baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer!, 0)
            
            let buffer = baseAddress!.assumingMemoryBound(to: UInt8.self)
            
            var highestIntensity  = CGFloat.leastNormalMagnitude;
            var highestIntensityPoint = CGPoint(x: -1, y: -1);
            
            if (planeWidth != CVPixelBufferGetWidthOfPlane(pixelBuffer!,0)){
                print("getting pixelBuffer properties")
                //the width and height appear to be the same dimensions, the big difference is the numpixelsperrow
                planeWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer!, 0)
                planeHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer!, 0)
                
                bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer!)
                bytesPerRowofPlane = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer!, 0)
                
                width = CVPixelBufferGetWidth(pixelBuffer!)
                height = CVPixelBufferGetHeight(pixelBuffer!)
                
                w = CGFloat(width)
                h = CGFloat(height)
                intensityThreshhold = getIntensityThreshold(mode: detectionMode)
            }

            //let pixelW : Int = 100
            
            var numBrightPixels = 0;
    
            for x in stride(from: 0, to: width, by: pixelsToSkip) {
                for y in stride(from: 0, to: height, by: pixelsToSkip) {
                    
                    let index = x +  y * bytesPerRowofPlane
                   // let isCosmicRay = false;
                    let intensity: CGFloat;
                    
                        intensity = (CGFloat(buffer[index]));

                    
                    if (intensity > getIntensityThreshold(mode: detectionMode)*0.75){
                        numBrightPixels += 1;
                        //moved inside to save on needless operations
                        if(intensity > highestIntensity){
                            highestIntensity = intensity;
                            highestIntensityPoint = CGPoint(x: x, y: y);
                        }
                    }
                }
            }

            if (numBrightPixels >= minRaySize
                && numBrightPixels <= (width*height)/4){
                /*
                let pixelX = highestIntensityPoint.x
                let pixelY = highestIntensityPoint.y
                let pixelW  : CGFloat = 100//CGFloat(width/200) //might have to play with this number; its the dimesionof the cropped image
                let rect = CGRect(x: pixelX - pixelW/2, y: pixelY - pixelW/2, width: pixelX + pixelW/2, height: pixelY + pixelW/2)
                let vec = CIVector(x: pixelX - pixelW/2, y: pixelY - pixelW/2, z: pixelX + pixelW/2, w: pixelY + pixelW/2)
                */
                numEvents += 1
                timeElapsed = CFAbsoluteTimeGetCurrent() -  timeStarted
                flux = Double(numEvents)/timeElapsed
                
                if (flux > targetFlux*1.5){
                    print("flux too high!")
                    return;
                }
                
                print("Found me a cosmic ray! \(highestIntensity) at \(highestIntensityPoint.x), \(highestIntensityPoint.y).  \(numEvents) events in \(timeElapsed) ms " )
                print("The flux is  \(flux) " )
                let percent = CGFloat (numBrightPixels) / (w * h)
                print("Percentage of Bright Pixels: \(percent * 100.0 )")
                print("Threshold is \(getIntensityThreshold(mode: detectionMode))")
                ciimage = CIImage(cvImageBuffer: pixelBuffer!)
                
               
            //    let filter = CIFilter(name: "CICrop", withInputParameters: ["inputImage" : ciimage, "inputRectangle" : vec])
                // print("filter is \(filter.debugDescription)")
              //  let filter = CIFilter(name : "CIExposureAdjust", withInputParameters: ["inputImage" : ciimage, "inputEV" : 0.6])//this to reduce noise to find btrightest point
         
              //  ciimage = filter!.outputImage!
                cgimage = ciContext.createCGImage(ciimage, from: ciimage.extent)
                
              // DetectionHelper.lastImage =  UIImage(cgImage: cgimage!)
                
                imageView.image =  UIImage(cgImage: cgimage!)
              //  DispatchQueue.main.sync{
                    UIImageWriteToSavedPhotosAlbum(imageView.image!, nil, nil, nil)
               // }
                AudioServicesPlayAlertSound(SystemSoundID(1322))

                //make the event
                let score : CGFloat = CGFloat(numBrightPixels)*intensityThreshhold
                let detection = Detection(image : imageView.image, score: Float32(score) )
               DispatchQueue.main.sync{
                FirebaseHelper.helper.addDetection(detection: detection)
                
             //   glView.bindDrawable()
                
               //     ciContext.draw(ciimage, in: glView.frame, from: ciimage.extent)
               //     glView.display()
                }
                
            }
            
            //release the buffer
            CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            break;
        
            
        case .DORMANT:
            glView.bindDrawable()
            if (glContext != nil && ciimage != nil){
                DispatchQueue.main.sync{
                    ciContext.draw(ciimage, in: glView.frame, from: ciimage.extent)
                    glView.display()
                }
                print("Put Phone Flat")
            }
            return;
        }
        
    }
/*need to stick this somewhere
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let data = data {
            DispatchQueue.main.async { // Correct
                self.label.text = "\(data.count) bytes downloaded"
            }
        }
    }
    task.resume()
    */
    
    //use this delegate method to see how many frames get dropped
    func droppedFrame() {
        droppedFrames = droppedFrames + 1
      //     print("Dropped frames : \(droppedFrames) out of \(numFrames) = \(CGFloat(droppedFrames*100)/CGFloat(numFrames))")
    }

    
   
    
    func getIntensityThreshold(mode: DetectionModes) -> CGFloat{
        for data in intensityThreshholds{
            let tempDetectionMode = data.0;
            if(mode == tempDetectionMode){
                return data.1
            }
            
        }
        print("Unable to Get Threshold")
        return 0;
    }
    func setIntensityThreshold(mode: DetectionModes, value: Double) -> Void{
        switch(mode){
        case .BGRA:
            intensityThreshholds[0].1 = CGFloat(value)
            
        case .YUV420v:
            intensityThreshholds[1].1 = CGFloat(value)
        }
        print("Changed intensity to \(getIntensityThreshold(mode: mode))")
        
    }
    func incrementIntensityThreshold(mode: DetectionModes, value: Double){
        setIntensityThreshold(mode: mode, value: Double(getIntensityThreshold(mode: mode))+(value))
    }
    
//MARK: Timer Methods
    @objc func updateThreshold(){
        timeElapsed = CFAbsoluteTimeGetCurrent() -  timeStarted
        flux = Double(numEvents)/timeElapsed
        if (flux > targetFlux){
            incrementIntensityThreshold(mode: detectionMode, value: 5)
            
        }
    }
    
    @objc func updateAcc() {

        if let ad = motionManager.accelerometerData {
            
            accData.x = ad.acceleration.x
            accData.y = ad.acceleration.y;
            accData.z = ad.acceleration.z;
   
        }
        isFlat = accData.z <= -0.95;

    }
    
    
}

