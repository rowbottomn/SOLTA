    //
    //  HistoryVC.swift
    //  trial 3
    //
    //  Created by Ansar Khan on 2018-05-31.
    //  Copyright © 2018 Guest User. All rights reserved.
    //
    import UIKit
    import Firebase;

    class HistoryVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
        
        var ref: DatabaseReference!
        let storageRef = Storage.storage().reference()
   
        @IBOutlet weak var tableView: UITableView!
   
        var detections = [Detection]()
        
        override func viewDidLoad() {
           //   detections = FirebaseHelper.helper.populateCells()
            super.viewDidLoad()

            tableView.backgroundColor = UIColor(red: 245.0/255.0, green: 244.0/255.0, blue: 240.0/255.0, alpha: 1)
           // detections.append(Detection(image: UIImage(named: "pic1.jpg"), score: 111011))
            
            populateCells()
            tableView.delegate = self
            tableView.dataSource = self
            // Do any additional setup after loading the view.
               // self.tableView.reloadData()
            
        }
        
        func populateCells() -> [Detection]{
            
            let user = Auth.auth().currentUser

            let userRef = FirebaseHelper.helper.getUserRef(user: user!)
            let userStorageRef = FirebaseHelper.helper.getStorageRef(user: user!)
            
            var eventsFromFirebase = [Detection]()
            let eventData = userRef.observe(.value, with: {(snapShot) in
            if snapShot.exists(){
                for rest in snapShot.children.allObjects as! [DataSnapshot] {
                    print("should I look at you: \(rest.hasChild("url"))" )
                    print(rest.value)
                    if rest.hasChild("url") {
                        eventsFromFirebase.append(Detection(snapshot: rest))
                        print("adding \(eventsFromFirebase.count)")
                    }
                }
                self.detections = eventsFromFirebase
                print(self.detections.count)
                self.tableView.reloadData()
            
            }
            
            })//queryOrdered(byChild: "score")
            
            // let test = scoreBasedHitsQuery.dictionaryWithValues(forKeys: ["score","date"])
            // test.count
            //print("Query Result: \(scoreBasedHitsQuery)")
            return eventsFromFirebase
        }
        

        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
            print("tableview cell")
            return detections.count
            
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as? HistoryTableViewCell
            
            cell?.scoreField.text = "Score: \(detections[indexPath.item].score)"
            cell?.timeField.text = "Time: \(detections[indexPath.item].millis)"
            cell?.thumbnail.image = detections[indexPath.item].image
            return cell!
        }

        
        
}
