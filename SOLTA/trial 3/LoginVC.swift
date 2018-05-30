//
//  LoginVC.swift
//  trial 3
//
//  Created by Nathan Rowbottom on 2018-05-30.
//  Copyright © 2018 Guest User. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginVC: UIViewController, GIDSignInDelegate {
    
    
    
    @IBAction func googleLoginDidTapped(_ sender: Any) {
        print("login google did tapped")
        
        if (GIDSignIn.sharedInstance().currentUser == nil){
            print("No user logged in yet")
            GIDSignIn.sharedInstance().signIn()
        }
        else {
            print("Domain: \(GIDSignIn.sharedInstance().currentUser.userID)")
            
            GIDSignIn.sharedInstance().signOut()
        }
        /*   Firebase.Auth.auth().signInAnonymously(completion: {(anonymousUser:User?, error:Error?) in
         print("Inside callback")
         if error == nil{
         print("Success!")
         print("The userID is \(anonymousUser!.uid)")
         }
         else{
         print(error?.localizedDescription ?? "It was nil? WTF??")
         }
         
         } as AuthResultCallback)*/
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print(user.authentication)
        LoginHelper.helper.loginWithGoogle(auth: user.authentication)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
