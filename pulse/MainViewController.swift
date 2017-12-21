//
//  MainViewController.swift
//  pulse
//
//  Created by Rob Broadwell on 12/18/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {

    @IBOutlet weak var loginContainerView: UIView!
    @IBOutlet weak var mapContainerView: UIView!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            if Auth.auth().currentUser == nil {
                self.showLogin()
                
            } else {
                self.showMap()
                userLocation.setupLocationManager()
                firebase.initializeUserObservers()
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
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public func showMap() {
        loginContainerView.isHidden = true
        mapContainerView.isHidden = false
    }
    
    public func showLogin() {
        loginContainerView.isHidden = false
        mapContainerView.isHidden = true
    }

}
