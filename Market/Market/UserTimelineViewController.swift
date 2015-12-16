//
//  UserTimelineViewController.swift
//  Market
//
//  Created by Dave Vo on 12/12/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import MBProgressHUD

class UserTimelineViewController: UIViewController {
  
  var user: User!
  var posts = [Post]()
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var userLabel: UILabel!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var bigAvatarImageView: UIImageView!
  
  @IBOutlet weak var followingCountLabel: UILabel!
  @IBOutlet weak var followerCountLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    userLabel.text = user.fullName
    avatarImageView.setImageWithURL(NSURL(string: user.avatar!.url!)!)
    avatarImageView.layer.cornerRadius = 40
    avatarImageView.clipsToBounds = true
    bigAvatarImageView.image = avatarImageView.image
    bigAvatarImageView.clipsToBounds = true
    
    tableView.dataSource = self
    tableView.delegate = self
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    loadData()
  }
  
  func loadData() {
    user.getPosts(NSDate(), callback: { (posts, error) -> Void in
      if let posts = posts {
        if posts.count == 0 {
          //self.isEndOfFeed = true
        }
        
        for p in posts {
          self.posts.append(p)
        }
        self.tableView.reloadData()
        
      } else {
        print(error)
        //self.isEndOfFeed = true
      }
      
      //self.noMoreResultLabel.hidden = !self.isEndOfFeed
      //self.refreshControl.endRefreshing()
      //self.loadingView.stopAnimating()
      //self.isLoadingNextPage = false
      MBProgressHUD.hideHUDForView(self.view, animated: true)
    })
  }
  
  @IBAction func onBack(sender: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}

extension UserTimelineViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("simplifiedItemCell", forIndexPath: indexPath) as! SimplifiedItemCell
    cell.item = posts[indexPath.row]
    
    return cell
  }
}
