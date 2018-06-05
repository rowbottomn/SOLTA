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
        
   
        @IBOutlet weak var tableView: UITableView!
   
        var detections = [Detection]()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.delegate = self;
            tableView.dataSource = self
            tableView.backgroundColor = UIColor(red: 245.0/255.0, green: 244.0/255.0, blue: 240.0/255.0, alpha: 1)
            detections.append(Detection(image: UIImage(named: "pic1.jpg"), score: 111011))

            FirebaseHelper.helper.populateCells()
            // Do any additional setup after loading the view.
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
            return detections.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as? HistoryTableViewCell
            
            cell?.scoreField.text = "Score: \(detections[indexPath.item].score)"
            cell?.timeField.text = "Time: \(detections[indexPath.item].dateString)"
            cell?.thumbnail.image = detections[indexPath.item].image
            return cell!
        }

        
        
}
