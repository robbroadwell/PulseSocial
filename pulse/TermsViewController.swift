//
//  TermsViewController.swift
//  pulse
//
//  Created by Rob Broadwell on 1/18/18.
//  Copyright © 2018 Rob Broadwell LTD. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {
    
    @IBAction func pop(_ sender: Any) {
        self.navigationController?.dismiss(animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
