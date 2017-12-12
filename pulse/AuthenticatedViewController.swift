//
//  AuthenticatedViewController.swift
//  pulse
//
//  Created by Rob Broadwell on 5/26/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit
import Firebase

class AuthenticatedViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?

    func createAuthStateListener() {
        
        handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            if Auth.auth().currentUser == nil {
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "loginVC")
                self.present(vc, animated: true, completion: nil)
            } else {
                
            }
        }
    }
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
