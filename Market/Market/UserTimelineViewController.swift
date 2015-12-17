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
  var isCurrentUser = false
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var userLabel: UILabel!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var bigAvatarImageView: UIImageView!
  
  @IBOutlet weak var followingCountLabel: UILabel!
  @IBOutlet weak var followerCountLabel: UILabel!
  @IBOutlet weak var editProfileButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
  }
  
  override func viewWillAppear(animated: Bool) {
    if user == nil {
      user = User.currentUser()
      isCurrentUser = true
    }
    print("loading \(user.fullName)")
    editProfileButton.hidden = !isCurrentUser
    
    userLabel.text = user.fullName
    avatarImageView.setImageWithURL(NSURL(string: user.avatar!.url!)!)
    avatarImageView.layer.cornerRadius = 40
    avatarImageView.clipsToBounds = true
    bigAvatarImageView.setImageWithURL(NSURL(string: user.avatar!.url!)!)
    bigAvatarImageView.clipsToBounds = true
    
    tableView.dataSource = self
    tableView.delegate = self
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    posts = []
    loadData()
  }
  
  func loadData() {
    print("in loadData")
    user.getPosts(NSDate(), callback: { (posts, error) -> Void in
      print("loading user's post")
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
  
  func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    // If this is my post then allow these actions
    if isCurrentUser {
      let post = posts[indexPath.row]
      
      let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
        // Delete post
        
        let alertController = UIAlertController(title: "Market", message: "Are you sure to delete this post?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
          print(action)
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
          Post.deletePost(post.objectId!, completion: { (finished, error) -> Void in
            if finished {
              self.posts.removeAtIndex(indexPath.row)
              tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
            } else {
              print("failed to delete post, error = \(error)")
            }
          })
        }
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
      }
      deleteAction.backgroundColor = MyColors.carrot
      
      let editAction = UITableViewRowAction(style: .Normal, title: "Edit") { action, index in
        // Edit post
      }
      editAction.backgroundColor = MyColors.bluesky
      
      return [deleteAction, editAction]
    }
    return []
  }
}
