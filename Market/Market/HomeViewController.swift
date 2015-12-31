//
//  HomeViewController.swift
//  Market
//
//  Created by Dave Vo on 12/3/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//
// #139EEC

import UIKit
import MBProgressHUD
import Parse

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var refreshControl = UIRefreshControl()
    var loadingView: UIActivityIndicatorView!
    var isLoadingNextPage = false
    var isEndOfFeed = false
    var noMoreResultLabel = UILabel()
    var selectedPostIndex: Int!
    
    var posts = [Post]()
    var loadDataBy = NewsfeedType.Newest
    
    
    static func gotoHome() {
        let vc = StoryboardInstance.home.instantiateViewControllerWithIdentifier(StoryboardID.home)
        UIApplication.sharedApplication().delegate!.window!!.rootViewController = vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForInstallation()
        TabBarController.instance.initTabBar(self.tabBarController!)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Refresh control
        refreshControl.addTarget(self, action: Selector("pullNewestData"), forControlEvents: UIControlEvents.ValueChanged)
        updateRefreshControl()
        tableView.insertSubview(refreshControl, atIndex: 0)
        
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
        
        let navController = tabBarController?.viewControllers![2] as! UINavigationController
        let postVC: PostViewController = navController.topViewController as! PostViewController
        postVC.delegate = self
        let hud = MBProgressHUD.showHUDAddedTo(tableView, animated: true)
        hud.labelText = "Loading \(loadDataBy.name)..."
        loadData(nil)
        
        initTabBar()
    }
    
    func pullNewestData() {
        loadData(nil)
    }
    
    func initTabBar() {
        if let tabBarItem = tabBarController?.tabBar.items![1] {
            tabBarItem.image = UIImage(named: "message")
            tabBarItem.title = "Messages"
        }
        if let tabBarItem = tabBarController?.tabBar.items![3] {
            tabBarItem.image = UIImage(named: "noti")
            tabBarItem.title = "Notifications"
        }
    }
    
    func setupForInstallation() {
        if let currentUser = User.currentUser() {
            let installation = PFInstallation.currentInstallation()
            installation["user"] = currentUser
            installation.saveInBackground()
            currentUser.updateNotificationSettings()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Reload whatever the change from other pages
        //        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Clear the selection of tableView
        if selectedPostIndex != nil {
            tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: selectedPostIndex), animated: true)
        }
    }
    
    func loadData(lastCreatedAt: NSDate?) {
        
        Post.getNewsfeed(loadDataBy, lastCreatedAt: lastCreatedAt) { (posts, error) -> Void in
            if let posts = posts {
                if posts.count == 0 {
                    self.isEndOfFeed = true
                }
                if lastCreatedAt == nil {
                    self.posts = posts
                } else {
                    self.posts.appendContentsOf(posts)
                }
                self.tableView.reloadData()
                
                if lastCreatedAt == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.scrollToTop()
                    })
                }
                
            } else {
                if error?.code == PFErrorCode.ErrorInvalidSessionToken.rawValue {
                    User.logOut()
                    ViewController.gotoMain()
                    return
                }
                print(error)
                self.isEndOfFeed = true
            }
            self.noMoreResultLabel.hidden = !self.isEndOfFeed
            self.refreshControl.endRefreshing()
            self.loadingView.stopAnimating()
            self.isLoadingNextPage = false
            MBProgressHUD.hideHUDForView(self.tableView, animated: true)
        }
    }
    
    func scrollToTop() {
        if tableView.numberOfSections > 0 {
            let top =  NSIndexPath(forItem: NSNotFound, inSection: 0)
            tableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    @IBAction func onCategoryChanged(sender: UISegmentedControl) {
        isEndOfFeed = false
        switch sender.selectedSegmentIndex {
        case 0:
            loadDataBy = NewsfeedType.Newest
        case 1:
            loadDataBy = NewsfeedType.Following
        case 2:
            loadDataBy = NewsfeedType.UsersVote
        default:
            loadDataBy = NewsfeedType.Newest
        }
        updateRefreshControl()
        let hud = MBProgressHUD.showHUDAddedTo(tableView, animated: true)
        hud.labelText = "Loading \(loadDataBy.name)..."
        loadData(nil)
    }
    
    func updateRefreshControl() {
        var strToBold = "Newest"
        switch segmentControl.selectedSegmentIndex {
        case 1:
            loadDataBy = NewsfeedType.Following
            strToBold = "Following"
        case 2:
            loadDataBy = NewsfeedType.UsersVote
            strToBold = "Users' vote"
        default:
            break
        }
        
        let message = "Loading \(strToBold)..."
        refreshControl.attributedTitle = message.bold(strToBold)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detailSegue") {
            if let detailVC = segue.destinationViewController as? DetailViewController {
                if let data = sender as? Post {
                    detailVC.post = data
                    detailVC.delegate = self
                }
            }
        } else if (segue.identifier == "userTimelineSegue") {
            if let userTimelineVC = segue.destinationViewController as? UserTimelineViewController {
                if let data = sender as? User {
                    userTimelineVC.user = data
                }
            }
        }
    }
    
}

extension HomeViewController: DetailViewControllerDelegate {
    func detailViewController(detailViewController: DetailViewController, newPost: Post) {
        print("Newfeeds got signal from detail page")
        posts[selectedPostIndex] = newPost
        
        let rowToReload: NSIndexPath = NSIndexPath(forRow: selectedPostIndex, inSection: 0)
        tableView.reloadRowsAtIndexPaths([rowToReload], withRowAnimation: .Automatic)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource, ItemCellDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if posts.count == 0 {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("itemCell") as! ItemCell
        
        cell.item = posts[indexPath.row]
        cell.delegate = self
        
        // Infinite load if about to reach last cell
        if !isLoadingNextPage && !isEndOfFeed {
            if indexPath.row >= posts.count - 2 {
                loadingView.startAnimating()
                isLoadingNextPage = true
                loadData(posts[posts.count-1].createdAt!)
            }
        }
        
        return cell
    }
    
    func itemCell(itemCell: ItemCell, didChangeSave value: Bool) {
        let indexPath = tableView.indexPathForCell(itemCell)!
        print("Newfeeds: save changed to \(value)")
        posts[indexPath.row].iSaveIt = value
    }
    
    func itemCell(itemCell: ItemCell, didChangeVote value: Bool, voteCount: Int) {
        let indexPath = tableView.indexPathForCell(itemCell)!
        print("Newfeeds: vote changed to \(value)")
        posts[indexPath.row].iVoteIt = value
        posts[indexPath.row].voteCounter = voteCount
    }
    
    func itemCell(itemCell: ItemCell, tapOnProfile value: Bool) {
        print(itemCell.item.user.fullName)
        if itemCell.item.user.objectId == User.currentUser()?.objectId {
            // I'm tap on myself
            self.tabBarController!.selectedIndex = 4
        } else {
            performSegueWithIdentifier("userTimelineSegue", sender: itemCell.item.user)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedPostIndex = indexPath.row
        let item = posts[indexPath.row]
        performSegueWithIdentifier("detailSegue", sender: item)
    }
    
}

extension HomeViewController: PostViewControllerDelegate {
    func postViewController(postViewController: PostViewController, didUploadNewPost post: Post) {
        print("i get new post, reload now")
        posts.insert(post, atIndex: 0)
        tableView.reloadData()
    }
}