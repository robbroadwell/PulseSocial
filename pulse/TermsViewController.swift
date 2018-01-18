//
//  TermsViewController.swift
//  pulse
//
//  Created by Rob Broadwell on 1/18/18.
//  Copyright © 2018 Rob Broadwell LTD. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var agreeButton: UIButton!
    
    @IBAction func pop(_ sender: Any) {
        self.navigationController?.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        textView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
        textView.scrollTo(direction: .top, animated: false)
        agreeButton.isUserInteractionEnabled = false
        agreeButton.backgroundColor = UIColor.lightGray
    }
    
    override func viewDidLayoutSubviews() {
        textView.scrollTo(direction: .top, animated: false)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            agreeButton.isUserInteractionEnabled = true
            agreeButton.backgroundColor = UIColor.init(red: 14/255,
                                                       green: 6/255,
                                                       blue: 118/255, alpha: 1)
        }
        
        if (scrollView.contentOffset.y <= 0){
            //reach top
        }
        
        if (scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < (scrollView.contentSize.height - scrollView.frame.size.height)){
            agreeButton.isUserInteractionEnabled = false
            agreeButton.backgroundColor = UIColor.lightGray
        }
    }
}
