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
        let credential =
            
            GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        
        user = GIDSignIn.sharedInstance().currentUser
        Auth.auth().signIn(with: credential, completion: {(user : User?, error : Error?)
            in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            else {
                print(user!.email?.debugDescription ?? "No user I guess")
                print(user!.displayName?.debugDescription ?? "Noah Boddy")
                self.switchToSetUserName()
            }
        })
    }
    
    private func switchToSetUserName(){
        let storyboard = UIStoryboard(name : "Main", bundle: nil)
        
        let nextVC = storyboard.instantiateViewController(withIdentifier: "SetNameVC") as! SetNameVC
        
        //get the appdelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController?.present(nextVC, animated:true, completion:nil)
        
    }
    
    func logOut(){
        GIDSignIn.sharedInstance().signOut()
        
    }
    
}
