//
//  UserTimelineViewController.swift
//  Market
//
//  Created by Dave Vo on 12/12/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import MBProgressHUD
import MGSwipeTableCell

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
    @IBOutlet weak var followButtonView: UIView!
    @IBOutlet weak var keywordText: UITextField!
    
    @IBOutlet weak var receiveNotificationView: UIView!
    @IBOutlet weak var keywordView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var segmentPreGap: NSLayoutConstraint!
    @IBOutlet weak var segmentHeight: NSLayoutConstraint!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        
        initControls()
        refreshProfile()
        
        MBProgressHUD.showHUDAddedTo(tableView, animated: true).applyCustomTheme(nil)
        loadNewestData()
    }
    
    func initControls() {
        backButton.layer.cornerRadius = 3
        followButton.layer.cornerRadius = 3
        editProfileButton.layer.cornerRadius = 3
        
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        keywordText.delegate = self
        
        keywordView.hidden = true
        receiveNotificationView.hidden = true
        
        activityIndicator.stopAnimating()
        
        // Refresh control
        refreshControl.addTarget(self, action: Selector("pullToRefresh"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapOnView:")
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        
        // Add the activity Indicator for table footer for infinity load
        let tableFooterView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
        loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingView.center = tableFooterView.center
        loadingView.hidesWhenStopped = true
        tableFooterView.insertSubview(loadingView, atIndex: 0)
        // Initialize the noMoreResult
        noMoreResultLabel.frame = tableFooterView.frame
        noMoreResultLabel.text = "No more result"
        noMoreResultLabel.textAlignment = NSTextAlignment.Center
        noMoreResultLabel.font = UIFont(name: noMoreResultLabel.font.fontName, size: 15)
        noMoreResultLabel.textColor = UIColor.grayColor()
        noMoreResultLabel.hidden = true
        tableFooterView.insertSubview(noMoreResultLabel, atIndex: 0)
        tableView.tableFooterView = tableFooterView
    }
    
    func tapOnView(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshProfile()
        if dataToLoad == .Following {
            refreshData(true)
        }
    }
    
    @IBAction func onBack(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onFollow(sender: UIButton) {
        followButton.enabled = false
        followButton.setTitle("", forState: .Normal)
        activityIndicator.startAnimating()
        if iFollowThisUser {
            Follow.unfollow(user, callback: { (success, error: NSError?) -> Void in
                self.followButton.enabled = true
                self.activityIndicator.stopAnimating()
                if success {
                    print("UnFollowing successfully \(self.user.fullName)")
                    self.iFollowThisUser = false
                    let count = Int(self.followerCountLabel.text!)! - 1
                    self.followerCountLabel.text = "\(count)"
                    self.followButton.setTitle("Follow", forState: .Normal)
                } else {
                    print("Can not unfollow \(self.user.fullName)", error)
                    self.followButton.setTitle("Unfollow", forState: .Normal)
                }
            })
        } else {
            Follow.follow(user, callback: { (success, error: NSError?) -> Void in
                self.followButton.enabled = true
                self.activityIndicator.stopAnimating()
                if success {
                    print("Follow successfully \(self.user.fullName)")
                    self.iFollowThisUser = true
                    let count = Int(self.followerCountLabel.text!)! + 1
                    self.followerCountLabel.text = "\(count)"
                    self.followButton.setTitle("Unfollow", forState: .Normal)
                } else {
                    print("Can't follow \(self.user.fullName)", error)
                    self.followButton.setTitle("Follow", forState: .Normal)
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
                MBProgressHUD.showHUDAddedTo(self.tableView, animated: true).applyCustomTheme(nil)
            }
            loadNewestData()
        case .Following:
            if !isPullToRefresh {
                MBProgressHUD.showHUDAddedTo(self.tableView, animated: true).applyCustomTheme(nil)
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
                    
                    if byThisDate == nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.scrollToTop()
                        })
                    }
                    
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
        }
        
        if user.objectId == User.currentUser()?.objectId {
            isCurrentUser = true
            segmentPreGap.constant = 10
            segmentHeight.constant = 28
            // Reload if any change in current user's profile
            user = User.currentUser()
        } else {
            isCurrentUser = false
            // Dont show the segment
            segmentPreGap.constant = 0
            segmentHeight.constant = 0
        }
        
        segmentControl.hidden = !isCurrentUser
        editProfileButton.hidden = !isCurrentUser
        backButton.hidden = isCurrentUser
        followButtonView.hidden = isCurrentUser
        
        if !isCurrentUser {
            followButton.setTitle("", forState: .Normal)
            followButton.enabled = false
            
            activityIndicator.startAnimating()
            user.didIFollowTheUser({ (followed, error) -> Void in
                self.iFollowThisUser = followed
                self.followButton.setTitle(followed ? "Unfollow" : "Follow", forState: .Normal)
                self.followButton.enabled = true
                self.activityIndicator.stopAnimating()
            })
        }
        
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
    
    func scrollToTop() {
        if tableView.numberOfSections > 0 {
            let top =  NSIndexPath(forItem: NSNotFound, inSection: 0)
            tableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
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
    
    //    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    //        view.endEditing(true)
    //    }
    
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
                useCreatedAt = true
                
                // If this is my post then allow these actions
                if user.objectId == User.currentUser()?.objectId {
                    // For left buttons
                    var buttonTitle = ""
                    var buttonColor = MyColors.green
                    
                    if cell.item.sold {
                        buttonTitle = "Avail"
                        buttonColor = MyColors.green
                    } else {
                        buttonTitle = "Sold"
                        buttonColor = MyColors.yellow
                    }
                    
                    let leftButton = MGSwipeButton(title: buttonTitle, backgroundColor: buttonColor
                        , callback: { (sender: MGSwipeTableCell!) -> Bool in
                            
                            let post = cell.item
                            let newCell = cell
                            
                            if !newCell.item.sold {
                                Post.sold(post, isSold: true, completion: { (finished, error) -> Void in
                                    if finished {
                                        newCell.soldView.hidden = false
                                        
                                        // Change button to "AVAIL"
                                        if let lb = newCell.leftButtons[0] as? MGSwipeButton {
                                            lb.backgroundColor = MyColors.green
                                            lb.setTitle("Avail", forState: UIControlState.Normal)
                                            
                                            // Resize the width to fit new text
                                            let newSize = lb.sizeThatFits(CGSize(width: CGFloat.max, height: cell.frame.height))
                                            lb.frame.size.width = newSize.width
                                        }
                                        
                                    } else {
                                        print("failed to sell post, error = \(error)")
                                    }
                                    newCell.item.fetchInBackground()
                                })
                                
                            } else {
                                Post.sold(post, isSold: false, completion: { (finished, error) -> Void in
                                    if finished {
                                        newCell.soldView.hidden = true
                                        
                                        // Change button to "Sold"
                                        if let lb = newCell.leftButtons[0] as? MGSwipeButton {
                                            lb.backgroundColor = MyColors.yellow
                                            lb.setTitle("Sold", forState: UIControlState.Normal)
                                            
                                            // Resize the width to fit new text
                                            let newSize = lb.sizeThatFits(CGSize(width: CGFloat.max, height: cell.frame.height))
                                            lb.frame.size.width = newSize.width
                                        }
                                        
                                    } else {
                                        print("failed to set post avail, error = \(error)")
                                    }
                                    newCell.item.fetchInBackground()
                                })
                            }
                            
                            return true
                    })
                    
                    // Enable expandable swipe
                    cell.leftButtons = [leftButton]
                    cell.leftSwipeSettings.transition = MGSwipeTransition.Border
                    cell.leftExpansion.buttonIndex = 0
                    cell.leftExpansion.threshold = 2.0
                    
                    // For right buttons
                    let delButton = MGSwipeButton(title: "Delete", backgroundColor: MyColors.carrot, callback: { (sender: MGSwipeTableCell!) -> Bool in
                        // Delete post
                        let newCell = sender as? SimplifiedItemCell
                        let post = newCell!.item
                        let id = tableView.indexPathForCell(newCell!)
                        
                        let alertController = UIAlertController(title: "Market", message: "Are you sure to delete this post?", preferredStyle: .Alert)
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                            print(action)
                            tableView.setEditing(false, animated: true)
                        }
                        alertController.addAction(cancelAction)
                        
                        let destroyAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
                            Post.deletePost(post.objectId!, completion: { (finished, error) -> Void in
                                if finished {
                                    print("delete at index \(id!.row)")
                                    self.posts.removeAtIndex(id!.row)
                                    tableView.deleteRowsAtIndexPaths([id!], withRowAnimation: .Bottom)
                                } else {
                                    print("failed to delete post, error = \(error)")
                                }
                            })
                        }
                        alertController.addAction(destroyAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        return true
                    })
                    
                    let editButton = MGSwipeButton(title: "Edit", backgroundColor: MyColors.bluesky, callback: { (sender: MGSwipeTableCell!) -> Bool in
                        let newCell = sender as? SimplifiedItemCell
                        let post = newCell!.item
                        let id = tableView.indexPathForCell(newCell!)
                        
                        self.selectedPostIndex = id!.row
                        self.performSegueWithIdentifier("editSegue", sender: post)
                        tableView.setEditing(false, animated: false)
                        
                        return true
                    })
                    
                    // Enable expandable swipe
                    cell.rightButtons = [delButton, editButton]
                    cell.rightSwipeSettings.transition = MGSwipeTransition.Border
                    cell.rightExpansion.buttonIndex = 0
                    cell.rightExpansion.threshold = 1.5
                }
                
            } else if dataToLoad == .UsersSavedPosts {
                
                // Add utility button Unsave on the right
                let unsaveButton = MGSwipeButton(title: "Unsave", backgroundColor: MyColors.bluesky, callback: { (sender: MGSwipeTableCell!) -> Bool in
                    //
                    let newCell = sender as? SimplifiedItemCell
                    let post = newCell!.item
                    let id = tableView.indexPathForCell(newCell!)
                    post.save(false) { (successful: Bool, error: NSError?) -> Void in
                        if successful {
                            print("unsaved at \(id!.row)")
                            self.posts.removeAtIndex(id!.row)
                            self.tableView.deleteRowsAtIndexPaths([id!], withRowAnimation: .Bottom)
                        } else {
                            print("failed to unsave")
                        }
                    }
                    
                    return true
                })
                
                // Enable expandable swipe
                cell.leftButtons = []
                cell.rightButtons = [unsaveButton]
                cell.rightSwipeSettings.transition = MGSwipeTransition.Border
                cell.rightExpansion.buttonIndex = 0
                cell.rightExpansion.threshold = 2.0
                
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
            
            let user = followingUsers[indexPath.row]
            
            cell.targetUser = user
            
            return cell
            
        case .Keywords:
            let cell = tableView.dequeueReusableCellWithIdentifier("KeywordsCell", forIndexPath: indexPath) as! KeywordsTableViewCell
            cell.keywordLabel.text = User.currentUser()?.keywords[indexPath.row]
            cell.delegate = self
            return cell
        }
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

extension UserTimelineViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let text = textField.text where textField == keywordText {
            if text.isEmpty {
                return false
            }
            onKeywordAdd(nil)
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == keywordText && string.characters.count > 0 {
            if string.containsString(" ") {
                return false
            }
        }
        return true
    }
}

// MARK: Show view from anywhere
extension UserTimelineViewController {
    static var instantiateViewController: UserTimelineViewController {
        return StoryboardInstance.home.instantiateViewControllerWithIdentifier(StoryboardID.userTimeline) as! UserTimelineViewController
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
