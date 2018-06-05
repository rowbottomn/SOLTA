//
//  DetectionVC.swift
//  trial 3
//
//  Created by Nathan Rowbottom on 2018-05-31.
//  Copyright © 2018 Guest User. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import CoreLocation
import GLKit
import AVFoundation
import CoreMotion
import CoreGraphics

class DetectionVC: UIViewController, CLLocationManagerDelegate , AVCaptureVideoDataOutputSampleBufferDelegate{

    @IBOutlet weak var b_StopCollecting: UIButton!
    @IBOutlet weak var DetectionView: UIImageView!
    
    
    //MARK: core location stuff
  //  let locationManager = CLLocationManager()
  //  var currentLocation : CLLocation?
 //   let regionRadius: CLLocationDistance = 5
    
    
    //MARK: Firebase related stuff
/*    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    var docRef : DocumentReference!
    var storageRef = Storage.storage().reference()
    var userRef = Database.database().reference()
    var detection = Detection()
  */
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        DetectionHelper.helper.viewController = self as DetectionVC
        DetectionHelper.helper.imageView = DetectionView
        DetectionHelper.helper.imageView = DetectionView//used capital letter for some reason
        DetectionHelper.helper.motionManager.startAccelerometerUpdates()
        DetectionHelper.helper.timer = Timer.scheduledTimer(timeInterval: 1, target: DetectionHelper.helper, selector: #selector(DetectionHelper.helper.updateAcc), userInfo: nil, repeats: true)
        DetectionHelper.helper.timer = Timer.scheduledTimer(timeInterval: 5, target: DetectionHelper.helper, selector: #selector(DetectionHelper.helper.updateThreshold), userInfo: nil, repeats: true)
        
        
        //  logAllFilters()
        DetectionHelper.helper.setupCameraSession()
        
    //   docRef = Firestore.firestore().document("Users/\(user?.uid)")
  //      let login = detection.getLoginFromEmail((user?.email)!)
        
 //       userRef = ref.child("\(login)")
//        locationManager.delegate = self"
        
 //       locationManager.requestWhenInUseAuthorization()
        
        //locationManager.startUpdatingLocation()
        
 //       locationManager.distanceFilter = 5
    }

    override func viewDidAppear(_ animated: Bool) {
        DetectionView.addSubview(DetectionHelper.helper.glView)
        if (!DetectionHelper.helper.cameraSession.isRunning){
            DetectionHelper.helper.cameraSession.startRunning()
        }
        print("cameraSession is \(DetectionHelper.helper.cameraSession.isRunning)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DetectionHelper.helper.capturedOutput(sampleBuffer: sampleBuffer)
    }
    
      func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DetectionHelper.helper.droppedFrame()
    }
    
    @IBAction func stopCollectingDidTap(_ sender: UIButton) {
        //for testing, make an event in both firebase and firestore
    //    let detection = Detection(location: CLLocation())
      //  let detection = Detection()
       // FirebaseHelper.helper.addDetection(detection: detection)
        //let date = detection.getDate()
        //let eventRef = userRef.child("\(date)")
        //eventRef.child("name").setValue(detection.user?.displayName)
        //eventRef.child("score").setValue( detection.score)
        
       // userRef.child("\(date)").setValue(["location" : detection.location.coordinate.latitude])
       // userRef.child("\(date)").setValue(["date" : date])
        //Need to dismiss the queue most likely
        DetectionHelper.helper.cameraSession.stopRunning()
        
    
    }

}

