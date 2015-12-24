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
    
    static let homeSB = UIStoryboard(name: "Home", bundle: nil)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var bigAvatarImageView: UIImageView!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var segmentPreGap: NSLayoutConstraint!
    @IBOutlet weak var segmentHeight: NSLayoutConstraint!
    
    var refreshControl = UIRefreshControl()
    var loadingView: UIActivityIndicatorView!
    var isLoadingNextPage = false
    var isEndOfFeed = false
    var noMoreResultLabel = UILabel()
    var selectedPostIndex: Int!
    var iFollowThisUser = false
    var dataToLoad = 0 // 0: user's posts, 1: user's saved posts
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        refreshProfile()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Refresh control
        refreshControl.addTarget(self, action: Selector("loadNewestData"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        // Add the activity Indicator for table footer for infinity load
        let tableFooterView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
        loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingView.center = tableFooterView.center
        loadingView.hidesWhenStopped = true
        tableFooterView.addSubview(loadingView)
        // Initialize the noMoreResult
        noMoreResultLabel.frame = tableFooterView.frame
        noMoreResultLabel.text = "No more result"
        noMoreResultLabel.textAlignment = NSTextAlignment.Center
        noMoreResultLabel.font = UIFont(name: noMoreResultLabel.font.fontName, size: 15)
        noMoreResultLabel.textColor = UIColor.grayColor()
        noMoreResultLabel.hidden = true
        tableFooterView.addSubview(noMoreResultLabel)
        tableView.tableFooterView = tableFooterView
        
        MBProgressHUD.showHUDAddedTo(tableView, animated: true)
        loadNewestData()
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshProfile()
    }
    
    func loadNewestData() {
        posts = []
        loadData(NSDate())
    }
    
    func loadDataSince(lastUpdatedAt: NSDate) {
        loadData(lastUpdatedAt)
    }
    
    func loadData(byThisDate: NSDate) {
        if dataToLoad == 0 {
            print("loading user's posts")
            user.getPosts(byThisDate, callback: { (posts, error) -> Void in
                if let posts = posts {
                    if posts.count == 0 {
                        self.isEndOfFeed = true
                    }
                    
                    for p in posts {
                        self.posts.append(p)
                    }
                    self.tableView.reloadData()
                    
                } else {
                    print(error)
                    self.isEndOfFeed = true
                }
                
                self.noMoreResultLabel.hidden = !self.isEndOfFeed
                self.refreshControl.endRefreshing()
                self.loadingView.stopAnimating()
                self.isLoadingNextPage = false
                MBProgressHUD.hideHUDForView(tableView, animated: true)
            })
            
        } else {
            print("loading user's saved posts")
            user.getSavedPosts(byThisDate, callback: { (posts, error) -> Void in
                if let posts = posts {
                    if posts.count == 0 {
                        self.isEndOfFeed = true
                    }
                    
                    for p in posts {
                        self.posts.append(p)
                    }
                    self.tableView.reloadData()
                    
                } else {
                    print(error)
                    self.isEndOfFeed = true
                }
                
                self.noMoreResultLabel.hidden = !self.isEndOfFeed
                self.refreshControl.endRefreshing()
                self.loadingView.stopAnimating()
                self.isLoadingNextPage = false
                MBProgressHUD.hideHUDForView(tableView, animated: true)
            })
        }
        
    }
    
    func refreshProfile() {
        if user == nil {
            user = User.currentUser()
            isCurrentUser = true
            segmentPreGap.constant = 15
            segmentHeight.constant = 28
        } else {
            if user.objectId == User.currentUser()?.objectId {
                isCurrentUser = true
                segmentPreGap.constant = 15
                segmentHeight.constant = 28
                // Reload if any change in current user's profile
                user = User.currentUser()
            } else {
                // Dont show the segment
                segmentPreGap.constant = 0
                segmentHeight.constant = 0
                user.didIFollowTheUser({ (followed, error) -> Void in
                    self.iFollowThisUser = followed
                    if followed {
                        self.followButton.setTitle("Unfollow", forState: .Normal)
                    } else {
                        self.followButton.setTitle("Follow", forState: .Normal)
                    }
                })
            }
        }
        
        segmentControl.hidden = !isCurrentUser
        editProfileButton.hidden = !isCurrentUser
        backButton.hidden = isCurrentUser
        followButton.hidden = isCurrentUser
        
        backButton.layer.cornerRadius = 3
        followButton.layer.cornerRadius = 3
        editProfileButton.layer.cornerRadius = 3
        
        // Load following (this user follows people)
        followingCountLabel.text = " "
        user.getNumFollowings { (numFollowing, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            self.followingCountLabel.text = "\(numFollowing)"
        }
        
        // Load follower (who follows this user)
        followerCountLabel.text = " "
        user.getNumFollowers { (numFollower, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            self.followerCountLabel.text = "\(numFollower)"
        }
        
        userLabel.text = user.fullName
        if let avatar = user.avatar {
            avatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
            bigAvatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
        } else {
            avatarImageView.image = UIImage(named: "profile_blank")
            bigAvatarImageView.image = UIImage(named: "profile_blank")
        }
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
        bigAvatarImageView.clipsToBounds = true
    }
    
    @IBAction func onBack(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setFollowersCounter(count: Int, followed: Bool) {
        followerCountLabel.text = "\(count)"
        if followed {
            followButton.setTitle("Unfollow", forState: .Normal)
        } else {
            followButton.setTitle("Follow", forState: .Normal)
        }
    }
    
    @IBAction func onFollow(sender: UIButton) {
        if iFollowThisUser {
            let count = Int(followerCountLabel.text!)! - 1
            setFollowersCounter(count, followed: false)
            
            Follow.unfollow(user, callback: { (success, error: NSError?) -> Void in
                if success {
                    print("UnFollowing successfully \(self.user.fullName)")
                    self.iFollowThisUser = false
                } else {
                    print("Can not unfollow \(self.user.fullName)", error)
                    self.setFollowersCounter(count + 1, followed: false)
                }
            })
            
        } else {
            let count = Int(followerCountLabel.text!)! + 1
            setFollowersCounter(count, followed: true)
            
            Follow.follow(user, callback: { (success, error: NSError?) -> Void in
                if success {
                    print("Follow successfully \(self.user.fullName)")
                    self.iFollowThisUser = true
                } else {
                    print("Can't follow \(self.user.fullName)", error)
                    self.followButton.setTitle("Follow", forState: .Normal)
                    self.setFollowersCounter(count - 1, followed: true)
                }
            })
        }
    }
    
    @IBAction func onCategoryChanged(sender: UISegmentedControl) {
        isEndOfFeed = false
        dataToLoad = sender.selectedSegmentIndex
        loadNewestData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navController = segue.destinationViewController as? UINavigationController {
            if let postVC = navController.topViewController as? PostViewController {
                postVC.delegate = self
                postVC.editingPost = sender as? Post
            }
        }
    }
}

// MARK: - Table View
extension UserTimelineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("simplifiedItemCell", forIndexPath: indexPath) as! SimplifiedItemCell
        
        // Dont know why but sometime it jumps to here
        // before data is reloaded (posts.count = 0) but indexPath.section = 4
        if posts.count == 0 {
            print("the myth")
            return cell
        }
        cell.item = posts[indexPath.row]
        
        // Infinite load if last cell
        if !isLoadingNextPage && !isEndOfFeed {
            if indexPath.row >= posts.count - 2 {
                loadingView.startAnimating()
                isLoadingNextPage = true
                loadDataSince(posts[posts.count-1].updatedAt!)
            }
        }
        
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
                    tableView.setEditing(false, animated: true)
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
                self.selectedPostIndex = indexPath.row
                let p = self.posts[self.selectedPostIndex]
                self.performSegueWithIdentifier("editSegue", sender: p)
                tableView.setEditing(false, animated: false)
            }
            editAction.backgroundColor = MyColors.bluesky
            
            return [deleteAction, editAction]
        }
        return []
    }
    
}

extension UserTimelineViewController: PostViewControllerDelegate {
    func postViewController(postViewController: PostViewController, didUploadNewPost post: Post) {
        print("i get updated post, reload now")
        posts[selectedPostIndex] = post
        let rowToReload: NSIndexPath = NSIndexPath(forRow: selectedPostIndex, inSection: 0)
        
        tableView.reloadRowsAtIndexPaths([rowToReload], withRowAnimation: UITableViewRowAnimation.Automatic)
        //tableView.reloadData()
    }
}

// MARK: Show view from anywhere
extension UserTimelineViewController {
    static var instantiateViewController: UserTimelineViewController {
        return homeSB.instantiateViewControllerWithIdentifier(StoryboardID.userTimeline) as! UserTimelineViewController
    }
}