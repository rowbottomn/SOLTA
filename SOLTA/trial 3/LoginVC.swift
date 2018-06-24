//
//  LoginVC.swift
//  trial 3
//
//  Created by Nathan Rowbottom on 2018-05-30.
//  Copyright © 2018 Guest User. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class LoginVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    
    @IBOutlet weak var b_SignIn: UIButton!
    
    @IBAction func googleSignInDidTap(_ sender: UIButton) {
   
        print("login google did tapped")
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
 
        if (GIDSignIn.sharedInstance().currentUser == nil){
            print("No user logged in yet")
            GIDSignIn.sharedInstance().signIn()
        }
        else {
            print("Domain: \(GIDSignIn.sharedInstance().currentUser.userID)")
            
            GIDSignIn.sharedInstance().signOut()
        }
    
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
       // print(user.authentication)
        LoginHelper.helper.loginWithGoogle(auth: user.authentication)
        FirebaseHelper.helper.locationInit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
