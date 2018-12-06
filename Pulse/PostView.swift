//
//  PostView.swift
//  pulse
//
//  Created by Rob Broadwell on 5/26/17.
//  Copyright © 2017 Rob Broadwell LTD. All rights reserved.
//

import UIKit

protocol PostViewDelegate {
    func updateUI()
}

class PostView: UIView, PostViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var viewModel: PostViewModel!
    
    func updateUI() {
        
        // initial post
        if let image = viewModel.image,
            let score = viewModel.score,
            let time = viewModel.time {
    
            imageView.image = image
            scoreLabel.text = String(score)
            timeLabel.text = timeAgoSinceDate(unix: time)
            setupReporting()
        }
        
        // updates
        guard let score = viewModel.score,
            let imageURL = viewModel.imageURL,
            let time = viewModel.time,
            let favorite = viewModel.isFavorite else { return }
        
        if imageView.image == nil {
            imageView.sd_setImage(with: URL(string: imageURL))
        }

        scoreLabel.text = String(score)
        upvoteButton.setImage(favorite ? #imageLiteral(resourceName: "favorite") : #imageLiteral(resourceName: "ic_favorite_border"), for: .normal)
        timeLabel.text = timeAgoSinceDate(unix: time)
        
        setupReporting()
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var reportTableView: UITableView!
    
    var blurView: UIView?
    var blurViewTwo: UIView?
    
    let reportTableData = ["Hide Post", "Hide Posts from this User", "Flag as Inappropriate"]
    
    @IBAction func upvoteWasPressed(_ sender: UIButton) {
        viewModel.favorite()
    }
    
    @IBAction func reportWasPressed(_ sender: UIButton) {
        
        if reportTableView.isHidden {
            
            let blurEffect = UIBlurEffect(style: .dark)
            blurView = UIVisualEffectView(effect: blurEffect)
            blurViewTwo = UIVisualEffectView(effect: blurEffect)
            blurView!.frame = self.bounds
            blurViewTwo!.frame = self.bounds
            blurView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurViewTwo!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(removeBlur))
            blurViewTwo?.addGestureRecognizer(tap)
            
            imageView.addSubview(blurView!)
            imageView.addSubview(blurViewTwo!)
            imageView.isUserInteractionEnabled = true
            
            reportTableView.isHidden = false
            
        } else {
            removeBlur()
        }
    }
    
    @objc func removeBlur() {
        blurView?.removeFromSuperview()
        blurViewTwo?.removeFromSuperview()
        reportTableView.isHidden = true
    }
    
    @IBAction func closeWasPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePost"), object: nil, userInfo: nil)
    }
    
    func setupReporting() {
        reportTableView.delegate = self
        reportTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = reportTableData[indexPath.row]
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
        
        var userInfoDict = [String : Any]()
        
        if indexPath.row == 0 {
            hidePost()
            userInfoDict["title"] = reportTableData[indexPath.row]
            userInfoDict["message"] = "The post has been hidden."
        } else if indexPath.row == 1 {
            hidePost()
            userInfoDict["title"] = reportTableData[indexPath.row]
            userInfoDict["message"] = "Posts from this user have been hidden."
        } else {
            hidePost()
            viewModel.flag()
            userInfoDict["title"] = reportTableData[indexPath.row]
            userInfoDict["message"] = "This user has been reported and you will no longer see posts from them. Depending on the severity of the offense you may be contacted via email by Pulse support."
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePost"), object: nil, userInfo: userInfoDict)
    
    }
    
    func hidePost() {
        var hiddenPosts = [String:Any]()
        if let hidden = UserDefaults.standard.dictionary(forKey: "hiddenPosts") {
            hiddenPosts = hidden
        }
        hiddenPosts[viewModel.key] = true
        UserDefaults.standard.set(hiddenPosts, forKey: "hiddenPosts")
        
        let userInfoDict: [String : Any] = ["key": viewModel.key]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removePost"), object: nil, userInfo: userInfoDict)
    }
    
    func hideUser() {
        
    
    }
    
    func reportPost() {
        
        
    }
    
    class func instanceFromNib() -> PostView {
        return UINib(nibName: "PostView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PostView
    }
}
