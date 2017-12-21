//
//  ResultsViewController.swift
//  pulse
//
//  Created by Rob Broadwell on 12/20/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import UIKit

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableData: [PostViewModel]?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        getData()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
        self.title = "\(firebase.visiblePosts.count) Results"
        getData()
    }
    
    func getData() {
        tableData = nil
        tableData = [PostViewModel]()
        
        for post in firebase.visiblePosts {
            tableData?.append(post.value)
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let postView = PostView.instanceFromNib()
        
        if let data = tableData {
            
            postView.viewModel = data[indexPath.row]
            postView.viewModel.delegate = postView
            postView.updateUI()
            postView.clipsToBounds = true
            postView.frame = cell.frame
            
            cell.addSubview(postView)
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
