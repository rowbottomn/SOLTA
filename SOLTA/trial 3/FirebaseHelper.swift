//
//  FirebaseHelper.swift
//  trial 3
//
//  Created by Nathan Rowbottom on 2018-05-31.
//  Copyright © 2018 Guest User. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation
import FirebaseStorage

struct Detection {
    
    let user = Auth.auth().currentUser
    
    var location =  CLLocation()
    var dateFormatter = DateFormatter()
    var date = Date()
    
    var image = UIImage(named: "2ndpage.png")
    
    init(location : CLLocation, image : UIImage? ){
        
        self.location = location
        date = Date()
        self.image = image
    }
    
}

class FirebaseHelper{
    static let helper = FirebaseHelper();
   
    //MARK: firebase references
   let ref = Database.database().reference()
   let user = Auth.auth().currentUser
   var storageRef = Storage.storage().reference()
   
    //MARK: class variables
    
   // var docRef = Firestore.firestore().document("D)
    
    
}
