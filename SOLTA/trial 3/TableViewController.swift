//
//  TableViewController.swift
//  trial 3
//
//  Created by Ansar Khan on 2018-05-31.
//  Copyright © 2018 Guest User. All rights reserved.
//

import UIKit
import Firebase;


class TableViewController: ViewController, UITableViewDelegate, UITableViewDataSource {

  
    var ref: DatabaseReference!
    
    
    
    @IBOutlet weak var tableView: UITableView!
    var detections = [Detection]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self;
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 245.0/255.0, green: 244.0/255.0, blue: 240.0/255.0, alpha: 1)
        detections.append(Detection())
        detections.append(Detection())

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detections.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? TableViewCell
        cell?.scoreField.text = "Score: "
        cell?.timeField.text = "Time: "
        
    
        
//        cell.textLabel?.text = detections[0].date.description
        
    
        
        return cell!
    }
    
    
    

    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}


