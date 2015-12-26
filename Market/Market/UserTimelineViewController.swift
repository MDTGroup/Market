//
//  UserTimelineViewController.swift
//  Market
//
//  Created by Dave Vo on 12/12/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import MBProgressHUD
import SWTableViewCell

class UserTimelineViewController: UIViewController {
    
    var user: User!
    var posts = [Post]()
    var queryArray = [User]()
    var keyWords = User.currentUser()?.keywords
    var isCurrentUser = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var bigAvatarImageView: UIImageView!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var keywordText: UITextField!
    
    @IBOutlet weak var keywordView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var segmentPreGap: NSLayoutConstraint!
    @IBOutlet weak var segmentHeight: NSLayoutConstraint!
    @IBOutlet weak var keywordViewHeight: NSLayoutConstraint!
    
    var refreshControl = UIRefreshControl()
    var loadingView: UIActivityIndicatorView!
    var isLoadingNextPage = false
    var isEndOfFeed = false
    var noMoreResultLabel = UILabel()
    var selectedPostIndex: Int!
    var iFollowThisUser = false
    var dataToLoad = 0 // 0: user's posts, 1: user's saved posts, 2: following, 3: keywords
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        refreshProfile()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Refresh control
        refreshControl.addTarget(self, action: Selector("refreshData"), forControlEvents: UIControlEvents.ValueChanged)
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
        MBProgressHUD.hideHUDForView(self.tableView, animated: true)
        isEndOfFeed = false
        dataToLoad = sender.selectedSegmentIndex
        keywordView.hidden = (dataToLoad != 3)
        keywordViewHeight.constant = dataToLoad != 3 ? 0 : 44
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        refreshData()
    }
    
    @IBAction func onKeywordAdd(sender: UIButton) {
        var addedString = ((keywordText?.text)!).lowercaseString
        addedString = addedString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if addedString.characters.count == 0 {
            return
        }
        User.currentUser()?.addKeyword(addedString, callback: { (success, error: NSError?) -> Void in
            if error != nil {
                if error?.code == 0 {
                    let alertController = UIAlertController(title: "Adding keyword", message: "The keyword existed", preferredStyle: .Alert)
                    
                    let ackAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
                        
                    }
                    alertController.addAction(ackAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                print(error)
                return
            } else {
                self.keywordText.text = ""
                self.keywordText.resignFirstResponder()
                self.tableView.reloadData()
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navController = segue.destinationViewController as? UINavigationController {
            if let postVC = navController.topViewController as? PostViewController {
                postVC.delegate = self
                postVC.editingPost = (sender as! Post)
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - Data fetching
extension UserTimelineViewController {
    func refreshData() {
        switch dataToLoad {
        case 0, 1:
            MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
            loadNewestData()
        case 2:
            MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
            loadFollowing()
        case 3:
            refreshControl.endRefreshing()
            tableView.reloadData()
        default: return
        }
    }
    
    func loadNewestData() {
        posts = []
        loadData(nil)
    }
    
    func loadDataSince(lastUpdatedAt: NSDate) {
        loadData(lastUpdatedAt)
    }
    
    func loadData(byThisDate: NSDate?) {
        if dataToLoad == 0 {
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
                MBProgressHUD.hideHUDForView(self.tableView, animated: true)
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
                MBProgressHUD.hideHUDForView(self.tableView, animated: true)
            })
        }
    }
    
    func refreshProfile() {
        keywordView.hidden = true
        keywordViewHeight.constant = 0
        if user == nil {
            user = User.currentUser()
            isCurrentUser = true
            segmentPreGap.constant = 10
            segmentHeight.constant = 28
        } else {
            if user.objectId == User.currentUser()?.objectId {
                isCurrentUser = true
                segmentPreGap.constant = 10
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
    
    // Load list of people I'm following
    func loadFollowing() {
        User.currentUser()?.getFollowings({ (users, error) -> Void in
            MBProgressHUD.hideHUDForView(self.tableView, animated: true)
            guard error == nil else {
                print(error)
                return
            }
            if let users = users {
                self.queryArray = users
                self.tableView.reloadData()
            }
            self.noMoreResultLabel.hidden = false
        })
    }
    
}

extension UserTimelineViewController: UITableViewDelegate, UITableViewDataSource, FollowingTableViewCellDelegate, KeywordsTableViewCellDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dataToLoad {
        case 0, 1: return posts.count
        case 2: return queryArray.count
        case 3:
            if let currentUser = User.currentUser() {
                return currentUser.keywords.count
            }
            return 0
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch dataToLoad {
        case 0, 1: return 60
        case 2: return 56
        case 3: return 40
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch dataToLoad {
        case 0, 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("simplifiedItemCell", forIndexPath: indexPath) as! SimplifiedItemCell
            
            // Dont know why but sometime it jumps to here
            // before data is reloaded (posts.count = 0) but indexPath.section = 4
            if posts.count == 0 {
                print("the myth")
                return cell
            }
            cell.item = posts[indexPath.row]
            
            if dataToLoad == 0 {
                // Add utility buttons
                let leftUtilityButtons = NSMutableArray()
                //let rightUtilityButtons = NSMutableArray()
                
                //rightUtilityButtons.sw_addUtilityButtonWithColor(MyColors.bluesky, icon: UIImage(named: "edit25"))
                //rightUtilityButtons.sw_addUtilityButtonWithColor(MyColors.carrot, icon: UIImage(named: "trash25"))
                
                if cell.item.sold {
                    leftUtilityButtons.sw_addUtilityButtonWithColor(MyColors.green, title: "Avail")
                } else {
                    leftUtilityButtons.sw_addUtilityButtonWithColor(MyColors.yellow, title: "Sold")
                }
                
                cell.leftUtilityButtons = leftUtilityButtons as [AnyObject]
                cell.rightUtilityButtons = [] //rightUtilityButtons as [AnyObject]
                cell.delegate = self
                
            } else if dataToLoad == 1 {
                // Add utility buttons
                let rightUtilityButtons = NSMutableArray()
                
                rightUtilityButtons.sw_addUtilityButtonWithColor(MyColors.bluesky, title: "Unsave")
                
                cell.leftUtilityButtons = []
                cell.rightUtilityButtons = rightUtilityButtons as [AnyObject]
                cell.delegate = self
            }
            
            // Infinite load if last cell
            if !isLoadingNextPage && !isEndOfFeed {
                if indexPath.row >= posts.count - 2 {
                    loadingView.startAnimating()
                    isLoadingNextPage = true
                    loadDataSince(posts[posts.count-1].createdAt!)
                }
            }
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell", forIndexPath: indexPath) as! FollowingTableViewCell
            
            if posts.count == 0 {
                print("the myth")
                return cell
            }
            
            let fullname = self.queryArray[indexPath.row].fullName
            cell.fullnameLabel.text = fullname
            if let avatarFile = self.queryArray[indexPath.row].avatar {
                avatarFile.getDataInBackgroundWithBlock{ (data: NSData?, error: NSError?) -> Void in
                    cell.imgField.image = UIImage(data: data!)
                }
            } else {
                cell.imgField.image = UIImage(named: "profile_blank")
            }
            
            cell.targetUser = self.queryArray[indexPath.row]
            cell.delegate = self
            
            // TODO: Infinite load if last cell
            // How to load next 20?
            
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("KeywordsCell", forIndexPath: indexPath) as! KeywordsTableViewCell
            cell.keywordLabel.text = User.currentUser()?.keywords[indexPath.row]
            cell.delegate = self
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if dataToLoad >= 1 {
            return []
        }
        
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
    
    func followingTableViewCell(followingTableViewCell: FollowingTableViewCell, didUnfollow value: Bool) {
        // Did unfollow this user, remove from the tableView
        if value {
            if let id = tableView.indexPathForCell(followingTableViewCell) {
                queryArray.removeAtIndex(id.row)
                tableView.deleteRowsAtIndexPaths([id], withRowAnimation: .Bottom)
            }
        }
    }
    
    func keywordsTableViewCell(keywordsTableViewCell: KeywordsTableViewCell, didDelete value: Bool) {
        if value {
            if let id = tableView.indexPathForCell(keywordsTableViewCell) {
                tableView.deleteRowsAtIndexPaths([id], withRowAnimation: .Bottom)
            }
        }
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

// MARK: - SWTableView
extension UserTimelineViewController: SWTableViewCellDelegate {
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
        // Update item as sold
        //        let alertController = UIAlertController(title: "Market", message: "Ok, sold!", preferredStyle: .Alert)
        //        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        //        alertController.addAction(okAction)
        //        self.presentViewController(alertController, animated: true, completion: nil)
        
        let id = tableView.indexPathForCell(cell)
        let post = posts[id!.row]
        
        if let newCell = cell as? SimplifiedItemCell {
            if newCell.priceLabel.text != "SOLD" {
                Post.sold(post.objectId!, isSold: true, completion: { (finished, error) -> Void in
                    if finished {
                        newCell.priceLabel.text = "SOLD"
                        newCell.priceLabel.backgroundColor = MyColors.carrot
                        
                        // Change button to "AVAIL"
                        let leftUtilityButtons = NSMutableArray()
                        leftUtilityButtons.sw_addUtilityButtonWithColor(MyColors.green, title: "Avail")
                        
                        newCell.leftUtilityButtons = leftUtilityButtons as [AnyObject]
                    } else {
                        print("failed to sell post, error = \(error)")
                    }
                })
                
            } else {
                Post.sold(post.objectId!, isSold: false, completion: { (finished, error) -> Void in
                    if finished {
                        newCell.priceLabel.text = self.posts[id!.row].price.formatCurrency()
                        newCell.priceLabel.backgroundColor = MyColors.bluesky
                        
                        // Change button to "Sold"
                        let leftUtilityButtons = NSMutableArray()
                        leftUtilityButtons.sw_addUtilityButtonWithColor(MyColors.yellow, title: "Sold")
                        newCell.leftUtilityButtons = leftUtilityButtons as [AnyObject]
                    } else {
                        print("failed to set post avail, error = \(error)")
                    }
                })
            }
            
        }
        cell.hideUtilityButtonsAnimated(true)
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        // Unsave item
        let id = tableView.indexPathForCell(cell)
        let post = posts[id!.row]
        post.save(false) { (successful: Bool, error: NSError?) -> Void in
            if successful {
                print("unsaved")
                self.posts.removeAtIndex(id!.row)
                self.tableView.deleteRowsAtIndexPaths([id!], withRowAnimation: .Bottom)
            } else {
                print("failed to unsave")
            }
        }
    }
}

// MARK: Show view from anywhere
extension UserTimelineViewController {
    static var instantiateViewController: UserTimelineViewController {
        return HomeViewController.storyboard.instantiateViewControllerWithIdentifier(StoryboardID.userTimeline) as! UserTimelineViewController
    }
}
