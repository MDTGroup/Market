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
    
    //    let postLimit = 12
    var user: User!
    var posts = [Post]()
    var followingUsers = [User]()
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
    
    @IBOutlet weak var receiveNotificationView: UIView!
    @IBOutlet weak var keywordView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var segmentPreGap: NSLayoutConstraint!
    @IBOutlet weak var segmentHeight: NSLayoutConstraint!
    @IBOutlet weak var switchControl: UISwitch!
    
    var refreshControl = UIRefreshControl()
    var loadingView: UIActivityIndicatorView!
    var isLoadingNextPage = false
    var isEndOfFeed = false
    var noMoreResultLabel = UILabel()
    var selectedPostIndex: Int!
    var iFollowThisUser = false
    var previousAvatarURL: String?
    
    enum DataToLoad: Int {
        case UsersPosts = 0
        case UsersSavedPosts = 1
        case Following = 2
        case Keywords = 3
    }
    
    private var dataToLoad = DataToLoad.UsersPosts
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.layer.cornerRadius = 3
        followButton.layer.cornerRadius = 3
        editProfileButton.layer.cornerRadius = 3
        
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
        
        refreshProfile()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        keywordText.delegate = self
        
        keywordView.hidden = true
        receiveNotificationView.hidden = true
        
        // Refresh control
        refreshControl.addTarget(self, action: Selector("pullToRefresh"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapOnView:")
        view.addGestureRecognizer(tapGesture)
        
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
    
    func tapOnView(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
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
        view.endEditing(true)
        
        if let currentUser = User.currentUser() {
            switch DataToLoad(rawValue: sender.selectedSegmentIndex)! {
            case DataToLoad.UsersSavedPosts:
                switchControl.on = currentUser.enableNotificationForSavedPosts
            case DataToLoad.Following:
                switchControl.on = currentUser.enableNotificationForFollowing
            case DataToLoad.Keywords:
                switchControl.on = currentUser.enableNotificationForKeywords
            default:
                break
            }
        }
        
        MBProgressHUD.hideHUDForView(self.tableView, animated: true)
        isEndOfFeed = false
        dataToLoad = DataToLoad(rawValue: sender.selectedSegmentIndex)!
        keywordView.hidden = dataToLoad != DataToLoad.Keywords
        receiveNotificationView.hidden = !(dataToLoad == .Keywords || dataToLoad == .Following || dataToLoad == .UsersSavedPosts)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        refreshData(false)
    }
    
    @IBAction func onKeywordAdd(sender: UIButton?) {
        var addedString = ((keywordText.text)!).lowercaseString
        addedString = addedString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        keywordText.resignFirstResponder()
        if addedString.characters.count == 0 {
            return
        }
        User.currentUser()?.addKeyword(addedString, callback: { (success, error: NSError?) -> Void in
            if error != nil {
                if error?.code == 0 {
                    AlertControl.show(self, title: "Adding keyword", message: "The keyword existed", handler: nil)
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
    
    func pullToRefresh() {
        refreshData(true)
    }
    
    func refreshData(isPullToRefresh: Bool) {
        switch dataToLoad {
        case .UsersPosts, .UsersSavedPosts:
            if !isPullToRefresh {
                MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
            }
            loadNewestData()
        case .Following:
            if !isPullToRefresh {
                MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
            }
            loadFollowing()
        case .Keywords:
            refreshControl.endRefreshing()
            tableView.reloadData()
        }
    }
    
    func loadNewestData() {
        posts = []
        loadData(nil)
    }
    
    func loadData(byThisDate: NSDate?) {
        if dataToLoad == .UsersPosts {
            user.getPosts(byThisDate, callback: { (posts, error) -> Void in
                if let posts = posts {
                    if byThisDate != nil {
                        self.posts.appendContentsOf(posts)
                    } else {
                        self.posts = posts
                    }
                    self.isEndOfFeed = posts.count == 0
                    self.tableView.reloadData()
                } else {                    print(error)
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
                    if byThisDate != nil {
                        self.posts.appendContentsOf(posts)
                    } else {
                        self.posts = posts
                    }
                    self.isEndOfFeed = posts.count == 0
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
        if let avatar = user.avatar, urlString = avatar.url {
            if urlString == previousAvatarURL {
                avatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
                bigAvatarImageView.setImageWithURL(NSURL(string: avatar.url!)!)
            } else {
                previousAvatarURL = urlString
                let url =  NSURL(string: urlString)!
                avatarImageView.alpha = 0
                bigAvatarImageView.alpha = 0
                
                avatarImageView.setImageWithURLRequest(NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 86400), placeholderImage: nil, success: { (urlRequest, httpURLResponse, image) -> Void in
                    self.avatarImageView.image =  image
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.avatarImageView.alpha = 1
                    })
                    }, failure: { (urlRequest, httpURLResponse, error) -> Void in
                        print(error)
                })
                
                bigAvatarImageView.setImageWithURLRequest(NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 86400), placeholderImage: nil, success: { (urlRequest, httpURLResponse, image) -> Void in
                    self.bigAvatarImageView.image =  image
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.bigAvatarImageView.alpha = 1
                    })
                    }, failure: { (urlRequest, httpURLResponse, error) -> Void in
                        print(error)
                })
            }
        } else {
            avatarImageView.noAvatar()
            bigAvatarImageView.noAvatar()
        }
    }
    
    // Load list of people I'm following
    func loadFollowing() {
        User.currentUser()?.getFollowings({ (users, error) -> Void in
            self.refreshControl.endRefreshing()
            MBProgressHUD.hideHUDForView(self.tableView, animated: true)
            guard error == nil else {
                print(error)
                return
            }
            if let users = users {
                self.followingUsers = users
                self.tableView.reloadData()
            }
            self.noMoreResultLabel.hidden = false
        })
    }
    
}

extension UserTimelineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dataToLoad {
        case .UsersPosts, .UsersSavedPosts:
            return posts.count
        case .Following:
            return followingUsers.count
        case .Keywords:
            if let currentUser = User.currentUser() {
                return currentUser.keywords.count
            }
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        view.endEditing(true)
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? SimplifiedItemCell {
            cell.hideUtilityButtonsAnimated(true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch dataToLoad {
        case .UsersPosts, .UsersSavedPosts:
            return 60
        case .Following:
            return 56
        case .Keywords:
            return 40
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch dataToLoad {
        case .UsersPosts, .UsersSavedPosts:
            let cell = tableView.dequeueReusableCellWithIdentifier("simplifiedItemCell", forIndexPath: indexPath) as! SimplifiedItemCell
            
            // Dont know why but sometime it jumps to here
            // before data is reloaded (posts.count = 0) but indexPath.section = 4
            if posts.count == 0 {
                print("the myth")
                return UITableViewCell()
            }
            if let user = user where dataToLoad == .UsersPosts {
                cell.profileId = user.objectId
            } else {
                cell.profileId = nil
            }
            cell.item = posts[indexPath.row]
            var useCreatedAt = true
            if dataToLoad == .UsersPosts {
                // Add utility buttons
                let leftUtilityButtons = NSMutableArray()
                
                if user.objectId == User.currentUser()?.objectId {
                    if cell.item.sold {
                        leftUtilityButtons.sw_addUtilityButtonWithColor(MyColors.green, title: "Avail")
                    } else {
                        leftUtilityButtons.sw_addUtilityButtonWithColor(MyColors.yellow, title: "Sold")
                    }
                }
                
                cell.leftUtilityButtons = leftUtilityButtons as [AnyObject]
                cell.rightUtilityButtons = []
                cell.delegate = self
                useCreatedAt = true
                
            } else if dataToLoad == .UsersSavedPosts {
                // Add utility buttons
                let rightUtilityButtons = NSMutableArray()
                
                rightUtilityButtons.sw_addUtilityButtonWithColor(MyColors.bluesky, title: "Unsave")
                
                cell.leftUtilityButtons = []
                cell.rightUtilityButtons = rightUtilityButtons as [AnyObject]
                cell.delegate = self
                useCreatedAt = false
            }
            
            // Infinite load if last cell
            if !isLoadingNextPage && !isEndOfFeed {
                if indexPath.row >= posts.count - 2 {
                    loadingView.startAnimating()
                    isLoadingNextPage = true
                    loadData(useCreatedAt ? posts[posts.count-1].createdAt! : posts[posts.count-1].updatedAt!)
                }
            }
            
            return cell
            
        case .Following:
            let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell", forIndexPath: indexPath) as! FollowingTableViewCell
            
            if followingUsers.count == 0 {
                print("followingUsers - the myth")
                return cell
            }
            
            if indexPath.row >= followingUsers.count {
                return UITableViewCell()
            }
            
            let fullname = followingUsers[indexPath.row].fullName
            cell.fullnameLabel.text = fullname
            if let avatarFile = followingUsers[indexPath.row].avatar {
                avatarFile.getDataInBackgroundWithBlock{ (data: NSData?, error: NSError?) -> Void in
                    cell.imgField.image = UIImage(data: data!)
                }
            } else {
                cell.imgField.noAvatar()
            }
            
            cell.targetUser = followingUsers[indexPath.row]
            
            // TODO: Infinite load if last cell
            // How to load next 20?
            
            return cell
            
        case .Keywords:
            let cell = tableView.dequeueReusableCellWithIdentifier("KeywordsCell", forIndexPath: indexPath) as! KeywordsTableViewCell
            cell.keywordLabel.text = User.currentUser()?.keywords[indexPath.row]
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if dataToLoad != .UsersPosts && dataToLoad != .UsersSavedPosts {
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if let followingCell = cell as? FollowingTableViewCell {
                let userTimelineVC = UserTimelineViewController.instantiateViewController
                userTimelineVC.user = followingCell.targetUser
                presentViewController(userTimelineVC, animated: true, completion: { () -> Void in
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                })
            } else if let simplifiedCell = cell as? SimplifiedItemCell {
                let detailVC = DetailViewController.instantiateViewController
                detailVC.post = simplifiedCell.item
                presentViewController(detailVC, animated: true, completion: { () -> Void in
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                })
            }
        }
    }
}

extension UserTimelineViewController: KeywordsTableViewCellDelegate {
    func keywordsTableViewCell(keywordsTableViewCell: KeywordsTableViewCell, keyword value: String) {
        AlertControl.showWithCancel(self, title: "Delete keyword", message: "Are you sure to delete keyword: \"\(value)\"", okHandler: { (okAction) -> Void in
            User.currentUser()?.removeKeyword(value, callback: { (success, error: NSError?) -> Void in
                guard error == nil else {
                    print(error)
                    return
                }
                if let id = self.tableView.indexPathForCell(keywordsTableViewCell) {
                    self.tableView.deleteRowsAtIndexPaths([id], withRowAnimation: .Bottom)
                }
            })
            }, cancelHandler: nil)
    }
}

extension UserTimelineViewController: PostViewControllerDelegate {
    func postViewController(postViewController: PostViewController, didUploadNewPost post: Post) {
        print("i get updated post, reload now")
        posts[selectedPostIndex] = post
        let rowToReload: NSIndexPath = NSIndexPath(forRow: selectedPostIndex, inSection: 0)
        
        tableView.reloadRowsAtIndexPaths([rowToReload], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}

// MARK: - SWTableView
extension UserTimelineViewController: SWTableViewCellDelegate {
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
        let id = tableView.indexPathForCell(cell)
        let post = posts[id!.row]
        
        if let newCell = cell as? SimplifiedItemCell {
            if !newCell.item.sold {
                Post.sold(post.objectId!, isSold: true, completion: { (finished, error) -> Void in
                    if finished {
                        newCell.soldView.hidden = false
                        
                        // Change button to "AVAIL"
                        let leftUtilityButtons = NSMutableArray()
                        leftUtilityButtons.sw_addUtilityButtonWithColor(MyColors.green, title: "Avail")
                        
                        newCell.leftUtilityButtons = leftUtilityButtons as [AnyObject]
                    } else {
                        print("failed to sell post, error = \(error)")
                    }
                    newCell.item.fetchInBackground()
                })
                
            } else {
                Post.sold(post.objectId!, isSold: false, completion: { (finished, error) -> Void in
                    if finished {
                        newCell.soldView.hidden = true
                        
                        // Change button to "Sold"
                        let leftUtilityButtons = NSMutableArray()
                        leftUtilityButtons.sw_addUtilityButtonWithColor(MyColors.yellow, title: "Sold")
                        newCell.leftUtilityButtons = leftUtilityButtons as [AnyObject]
                    } else {
                        print("failed to set post avail, error = \(error)")
                    }
                    newCell.item.fetchInBackground()
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

extension UserTimelineViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == keywordText {
            if textField.text!.isEmpty {
                return false
            }
            onKeywordAdd(nil)
        }
        return true
    }
}

// MARK: Show view from anywhere
extension UserTimelineViewController {
    static var instantiateViewController: UserTimelineViewController {
        return HomeViewController.storyboard.instantiateViewControllerWithIdentifier(StoryboardID.userTimeline) as! UserTimelineViewController
    }
}

// MARK: Update enable/disable notification settings
extension UserTimelineViewController {
    @IBAction func onChangeSwitchSaved(sender: UISwitch) {
        if let currentUser = User.currentUser() {
            switch dataToLoad {
            case .UsersSavedPosts:
                currentUser.updateNotificationConfigForType(NotificationSetting.SavedPosts, enable: sender.on)
            case .Following:
                currentUser.updateNotificationConfigForType(NotificationSetting.Following, enable: sender.on)
            case .Keywords:
                currentUser.updateNotificationConfigForType(NotificationSetting.Keywords, enable: sender.on)
            default:
                break
            }
        }
    }
}