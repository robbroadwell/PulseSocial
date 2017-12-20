//
//  PostViewController.swift
//  pulse
//
//  Created by Rob Broadwell on 12/20/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import Foundation
import UIKit

class PostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var tableData = [PostViewModel]()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let postView = PostView.instanceFromNib()
        
        postView.viewModel = tableData[indexPath.row]
        postView.viewModel.delegate = postView
        postView.updateUI()
        postView.clipsToBounds = true
        postView.frame = cell.frame
        
        cell.addSubview(postView)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func getData() {
        for post in firebase.posts {
            tableData.append(post.value)
        }
    }
    
    override func viewDidLoad() {
        getData()
        tableView.delegate = self
        tableView.dataSource = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        showPost(key: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public func showPost(key: String?) {
        
        guard firebase.posts.count > 0 else { return }
        
        var frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: scrollView.frame.width,
                                   height: scrollView.frame.height)
        
        if let key = key,
            let first = firebase.posts[key] {
            
            createPostView(inScrollView: scrollView, withFrame: frame, andViewModel: first)
            frame.origin.x = frame.origin.x + frame.width
            
        }
        
        for (this, viewModel) in firebase.posts {
            if this != key {
                
                createPostView(inScrollView: scrollView, withFrame: frame, andViewModel: viewModel)
                frame.origin.x = frame.origin.x + frame.width
                
            }
        }
        
        let content = CGRect(x: 0, y: 0,
                             width: scrollView.frame.width * CGFloat(firebase.posts.count),
                             height: scrollView.frame.height)
        
        scrollView.contentSize = content.size
        scrollView.scrollTo(direction: .left, animated: false)

    }
    
    private func createPostView(inScrollView scrollView: UIScrollView, withFrame frame: CGRect, andViewModel viewModel: PostViewModel) {
        let postView = PostView.instanceFromNib()
        
        postView.viewModel = viewModel
        postView.viewModel.delegate = postView
        postView.updateUI()
        postView.clipsToBounds = true
        postView.frame = frame
        
        scrollView.addSubview(postView)
    }
    
}
