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
    var dateString = ""
    var login = ""
    var millis : Double = 0
    var image = UIImage(named: "2ndpage.png")
    var imageURLString = "2ndpage.png"
    var imageURL = URL(string: "2ndpage.png")
    var score = Float32(0)
    var school = "Craig Kielburger Secondary School"
    
    
    /* Initializer for instantiating an object received from Firebase.
     */
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: Any]
        self.score = snapshotValue["score"] as! Float
        self.dateString = snapshotValue["date"] as! String
        self.date = getDate(string: dateString)
        self.imageURLString = snapshotValue["url"] as! String
        
        self.imageURL = URL(string: self.imageURLString)
        self.image = FirebaseHelper.helper.getImage(url: imageURLString)

    }

    
    init(location : CLLocation, image : UIImage? , score : Float32){
        dateFormatter.dateStyle = .full
        dateFormatter.timeZone =  TimeZone(abbreviation: "EST")
        
        self.location = location
        self.date = Date()
        self.dateString = getDate()
        self.image = image
                millis = (date.timeIntervalSince1970)
        self.login = getLoginFromEmail((user?.email)!)
        self.score = score
    //    print("\(user?.displayName), \(location.coordinate), \(dateFormatter.string(from: date)),\(score)")
        
    }
    
    init(image: UIImage? , score : Float){
        self.image = image
        
        self.score = score
        date = Date()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        dateFormatter.timeZone =  TimeZone(secondsFromGMT: -14400)
        millis = (date.timeIntervalSince1970)
        dateString = getDate()
        self.login = getLoginFromEmail((user?.email)!)
    }
    
    
    init(){
        date = Date()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        dateFormatter.timeZone =  TimeZone(secondsFromGMT: -14400)
        dateString = getDate()
                millis = (date.timeIntervalSince1970)
        self.login = getLoginFromEmail((user?.email)!)
        //   print("\(user?.displayName!), \(location.coordinate), \(dateFormatter.string(from: date)), \(score)")
    }
    
    func getDate() -> String{
        return dateFormatter.string(from: date)
    }
    
    func getDate(date : Date) -> String{
        return dateFormatter.string(from: date)
    }

    func getDate(string : String) -> Date{
        return dateFormatter.date(from: string)!
    }
    
    func getLoginFromEmail(_ email:String) -> String {

        let temp = user?.email?.description.replacingOccurrences(of: ".", with: "")//repmove any periods
        let parts = temp?.split(separator : "@")
        let login = parts![0].description
        return parts![0].description
    }
    
    mutating func updateURL(string : String){
        imageURL = URL(string: string)
    }
    
    mutating func updateURL(url : URL){
        imageURLString = url.absoluteString
    }
    
}

class FirebaseHelper{
    static let helper = FirebaseHelper();
   
    //MARK: firebase references
    var ref = Database.database().reference()
    let user = Auth.auth().currentUser
   // var docRef : DocumentReference!
    var storageRef = Storage.storage().reference()
    var userRef = Database.database().reference()

   var data = Data()
   var detections = [Detection]()
    
    var image = UIImage()
    
    //MARK: class variables
    
   // var docRef = Firestore.firestore().document("D)
    func eraseDetections(){
        detections = [Detection]()
    }
    
    func addDetection(detection : Detection){
        var currentDetection = detection
        let login = detection.login
        userRef = ref.child("\(login)")
        let userStorageRef = storageRef.child("\(login)")
        let date = detection.getDate()
        let eventRef = userRef.child("\(date)")
        let eventStorageRef = userStorageRef.child("\(date)")
        
        if (detection.image != nil){
            let imageStorageRef = eventStorageRef.child("\(Int32(detection.score)).png")
            data = UIImagePNGRepresentation(detection.image!)!
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            
            _ = imageStorageRef.putData(data, metadata: metadata, completion: { (metadata, error) in
                guard let metadata = metadata else {
                    print (error?.localizedDescription)
                    return
                }
                imageStorageRef.downloadURL(completion: {(url, error) in
                    if let error = error {
                        print("error getting url! \(error.localizedDescription)")
                        return
                    }
                    currentDetection.imageURL = url
                    currentDetection.updateURL(url: url!)
                    print("url is \(url?.absoluteString)")
                eventRef.child("url").setValue(currentDetection.imageURLString)
                    
                })

            })
        }
        eventRef.child("millis").setValue(currentDetection.user?.displayName)
        eventRef.child("score").setValue( currentDetection.score)
        eventRef.child("school").setValue( currentDetection.school)
        
        detections.append(currentDetection)
        //set the eventreference
        //set the storage reference
        //store the image reference and set the metadata
        //store on firebase the reference info
            //store the score
            //store the time running between occurances?
            //store the image download url
        
        
    }
    
    
    //not used
    func putImage(image : UIImage){
        data = UIImagePNGRepresentation(image)!

    }

    func getImage(url : String) -> UIImage{
        let downLoadRef = Storage.storage().reference(forURL: url)
        let downLoadTask = downLoadRef.getData(maxSize: 12*1024*1024,  completion: {(data, error) in
            if let data = data {
                let img = UIImage(data: data)
                self.image = img!
            }
            else {
                print("Error downloading image : \(error)")
            }
        })
        return image
    }
    
    func populateCells() {
        let eventsFromFirebase = [Detection]()
        let scoreBasedHitsQuery = userRef.observe(.value, with: {(snapShot) in
            if snapShot.exists(){
                print(snapShot.children)
                
            }
            
        })//queryOrdered(byChild: "score")
            
       // let test = scoreBasedHitsQuery.dictionaryWithValues(forKeys: ["score","date"])
       // test.count
        print("Query Result: \(scoreBasedHitsQuery)")
        
    }
    
    
    
    //????whys does the if not work???
    func removeDetection(detection : Detection){
        //hard to belive this is the best way to do this
        for (i, d) in detections.enumerated(){
          //  if (d !== detection){
          //      detections.remove(at: i)
          //  }
        }
    }
    
    
}
