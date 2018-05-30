//
//  LoginHelper.swift
//  trial 3
//
//  Created by Nathan Rowbottom on 2018-05-30.
//  Copyright © 2018 Guest User. All rights reserved.
//

import Firebase
import GoogleSignIn

class LoginHelper{
    
    
    static let helper =  LoginHelper()
    
    var user = GIDSignIn.sharedInstance().currentUser
    
    func loginWithGoogle(auth : GIDAuthentication)  {
        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        
        Firebase.Auth.auth().signIn(with: credential, completion: {(user : User?, error : Error?)
            in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            else {
                print(user!.email?.debugDescription ?? "No user I guess")
                print(user!.displayName?.debugDescription ?? "Noah Boddy")
                self.switchToNavigationVC()
            }
        })
    }
    
    private func switchToNavigationVC(){
        let storyboard = UIStoryboard(name : "Main", bundle: nil)
        
        let naviVC = storyboard.instantiateViewController(withIdentifier: "SetNameVC") as! UINavigationController
        
        //get the appdelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //set NAvigation controller as root view controller
        appDelegate.window?.rootViewController = naviVC
    }
    
    func logOut(){
        GIDSignIn.sharedInstance().signOut()
        
    }
    
}
