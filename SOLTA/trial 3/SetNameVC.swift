//
//  SetNameVC.swift
//  trial 3
//
//  Created by Nathan Rowbottom on 2018-05-30.
//  Copyright © 2018 Guest User. All rights reserved.
//

import UIKit

class SetNameVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tf_UserName: UITextField!
    
    var username : String = (LoginHelper.helper.user?.profile.givenName)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tf_UserName.delegate = self
        print("User logged in is : \(username)")
        tf_UserName.text = username
        tf_UserName.isUserInteractionEnabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   // func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
       // tf_UserName.resignFirstResponder()
   //     resignFirstResponder()
   // }
    @IBAction func startCollectingDidTap(_ sender: Any) {
      //  FirebaseHelper.helper.populateCells()
    }
    
}
