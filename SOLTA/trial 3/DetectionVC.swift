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

class DetectionVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var b_StopCollecting: UIButton!
    @IBOutlet weak var DetectionView: UIImageView!
    
    
    //MARK: core location stuff
  //  let locationManager = CLLocationManager()
  //  var currentLocation : CLLocation?
 //   let regionRadius: CLLocationDistance = 5
    
    
    //MARK: Firebase related stuff
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    var docRef : DocumentReference!
    var storageRef = Storage.storage().reference()
    var userRef = Database.database().reference()
    var detection = Detection()
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()

       docRef = Firestore.firestore().document("Users/\(user?.uid)")
        let login = detection.getLoginFromEmail((user?.email)!)
        
        userRef = ref.child("\(login)")
//        locationManager.delegate = self"
        
 //       locationManager.requestWhenInUseAuthorization()
        
        //locationManager.startUpdatingLocation()
        
 //       locationManager.distanceFilter = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stopCollectingDidTap(_ sender: UIButton) {
        //for testing, make an event in both firebase and firestore
    //    let detection = Detection(location: CLLocation())
        let detection = Detection()
        FirebaseHelper.helper.addDetection(detection: detection)
        //let date = detection.getDate()
        //let eventRef = userRef.child("\(date)")
        //eventRef.child("name").setValue(detection.user?.displayName)
        //eventRef.child("score").setValue( detection.score)
        
       // userRef.child("\(date)").setValue(["location" : detection.location.coordinate.latitude])
       // userRef.child("\(date)").setValue(["date" : date])
      
    }
    

}


