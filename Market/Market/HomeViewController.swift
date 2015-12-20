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
  
  var refreshControl = UIRefreshControl()
  var loadingView: UIActivityIndicatorView!
  var isLoadingNextPage = false
  var isEndOfFeed = false
  var noMoreResultLabel = UILabel()
  var selectedPostIndex: Int!

  var posts = [Post]()
  var loadDataBy = NewsfeedType.Newest
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupForInstallation()
    // Do any additional setup after loading the view, typically from a nib.
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
    
    let navController = tabBarController?.viewControllers![2] as! UINavigationController
    let postVC: PostViewController = navController.topViewController as! PostViewController
    postVC.delegate = self
    
    loadDataBy = NewsfeedType.Newest
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    loadNewestData()
    
    initTabBar()
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
    let installation = PFInstallation.currentInstallation()
    installation["user"] = User.currentUser()
    installation.saveInBackground()
  }
  
  override func viewWillAppear(animated: Bool) {
    // Reload whatever the change from other pages
    tableView.reloadData()
  }
  
  override func viewDidAppear(animated: Bool) {
    // Clear the selection of tableView
    if selectedPostIndex != nil {
      tableView.deselectRowAtIndexPath(NSIndexPath(forRow: selectedPostIndex, inSection: 0), animated: true)
    }
  }
  
  func loadNewestData() {
    posts = []
    loadData(["lastUpdatedAt": NSDate()])
  }
  
  func loadDataSince(lastUpdatedAt: NSDate) {
    loadData(["lastUpdatedAt": lastUpdatedAt])
  }
  
  func loadData(params: [String: NSDate]) {
    Post.getNewsfeed(loadDataBy, params: params) { (posts, error) -> Void in
      if let posts = posts {
        if posts.count == 0 {
          self.isEndOfFeed = true
        }
        
        self.posts.appendContentsOf(posts)
        self.tableView.reloadData()
        
      } else {
        print(error)
        self.isEndOfFeed = true
      }
      
      self.noMoreResultLabel.hidden = !self.isEndOfFeed
      self.refreshControl.endRefreshing()
      self.loadingView.stopAnimating()
      self.isLoadingNextPage = false
      MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
  }
  
  @IBAction func onCategoryChanged(sender: UISegmentedControl) {
    isEndOfFeed = false
    switch sender.selectedSegmentIndex {
    case 0: loadDataBy = NewsfeedType.Newest
    case 1: loadDataBy = NewsfeedType.Following
    case 2: loadDataBy = NewsfeedType.UsersVote
    default: loadDataBy = NewsfeedType.Newest
    }
    loadNewestData()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "detailSegue") {
      if let detailVC = segue.destinationViewController as? DetailViewController {
        detailVC.post = sender as? Post
        detailVC.delegate = self
      }
    } else if (segue.identifier == "userTimelineSegue") {
      if let userTimelineVC = segue.destinationViewController as? UserTimelineViewController {
        userTimelineVC.user = sender as? User
      }
    }
  }
  
}

extension NSDate {
  func dayBefore(nDays: Int) -> NSDate {
    let oneDay:Double = 60 * 60 * 24
    return self.dateByAddingTimeInterval(-oneDay * Double(nDays))
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
    let cell = tableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath) as! ItemCell
    
    // Dont know why but sometime it jumps to here
    // before data is reloaded (posts.count = 0) but indexPath.row = 4
    if posts.count == 0 {
      print("the myth")
      return cell
    }
    cell.item = posts[indexPath.row]
    cell.delegate = self
    
    // Infinite load if last cell
    if !isLoadingNextPage && !isEndOfFeed {
      if indexPath.row == posts.count - 1 {
        loadingView.startAnimating()
        isLoadingNextPage = true
        loadDataSince(cell.item.createdAt!)
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

