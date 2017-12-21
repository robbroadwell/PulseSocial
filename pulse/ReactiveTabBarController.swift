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
    
    enum tab: Int {
        case home = 0
        case results = 1
        case leaderboard = 2
        case favorites = 3
        case account = 4
    }
    
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
            var i = 0
            for item in items {
                if i == 1 || i == 4 {
                    item.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: -2, right: 0)
                    item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
                } else {
                    item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
                }
                i += 1
            }
        }
    }
    
    func updateResults(_ notification: NSNotification) {
        if let viewControllers = self.viewControllers {
            viewControllers[tab.results.rawValue].title = "\(firebase.visiblePosts.count) Results"
        }
    }
    
    func updateUserScore(_ notification: NSNotification) {
        if let viewControllers = self.viewControllers {
            viewControllers[tab.account.rawValue].title = "\(firebase.score)"
        }
    }
}
