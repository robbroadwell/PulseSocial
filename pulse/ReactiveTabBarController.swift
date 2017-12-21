//
//  ReactiveTabBarController.swift
//  pulse
//
//  Created by Rob Broadwell on 12/21/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import UIKit

class ReactiveTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        adjustInsets()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateResults(_:)), name: NSNotification.Name(rawValue: "updateResults"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUserScore(_:)), name: NSNotification.Name(rawValue: "updateUserScore"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateResults"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateUserScore"), object: nil)
    }
    
    func adjustInsets() {
        if let items = self.tabBar.items {
            for item in items {
                item.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            }
        }
    }
    
    func updateResults(_ notification: NSNotification) {
        if let viewControllers = self.viewControllers {
            viewControllers[1].title = "\(firebase.visiblePosts.count) Results"
        }
    }
    
    func updateUserScore(_ notification: NSNotification) {
        if let viewControllers = self.viewControllers {
            viewControllers[4].title = "\(firebase.score)"
        }
    }
}
