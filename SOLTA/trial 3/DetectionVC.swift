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

class DetectionVC: UIViewController {

    @IBOutlet weak var b_StopCollecting: UIButton!
    @IBOutlet weak var DetectionView: UIImageView!
    
    
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    var docRef : DocumentReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       docRef = Firestore.firestore().document("Users/\(user?.uid)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stopCollectingDidTap(_ sender: UIButton) {
        //for testing, make an event in both firebase and firestore
    //    let detection = Detection(location: CLLocation())
    }
    

}


