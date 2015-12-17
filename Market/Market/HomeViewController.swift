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

class HomeViewController: UIViewController {
  
  
  @IBOutlet weak var tableView: UITableView!
  
  var refreshControl = UIRefreshControl()
  var loadingView: UIActivityIndicatorView!
  var isLoadingNextPage = false
  var isEndOfFeed = false
  var noMoreResultLabel = UILabel()
  var selectedPostIndex: Int!
  
  //var items = [Item]()
  var posts = [Post]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    loadNewestData()
  }
  
  override func viewWillAppear(animated: Bool) {
    // Reload whatever the change from other pages
    print("new feeds will appear")
    tableView.reloadData()
  }
  
  func loadNewestData() {
    posts = []
    print("pull to refresh")
    loadData(["lastUpdatedAt": NSDate()])
  }
  
  func loadDataSince(lastUpdatedAt: NSDate) {
    loadData(["lastUpdatedAt": lastUpdatedAt])
  }
  
  func loadData(params: [String: NSDate]) {
    Post.getNewsfeed(NewsfeedType.Newest, params: params) { (posts, error) -> Void in
      if let posts = posts {
        print("return \(posts.count) posts")
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
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "detailSegue") {
      let detailVC: DetailViewController = segue.destinationViewController as! DetailViewController
      let data = sender as! Post
      detailVC.post = data
      detailVC.delegate = self
    } else if (segue.identifier == "userTimelineSegue") {
      let userTimelineVC: UserTimelineViewController = segue.destinationViewController as! UserTimelineViewController
      let data = sender as! User
      userTimelineVC.user = data
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
  }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource, ItemCellDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print("nrows = \(posts.count)")
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
        loadDataSince(cell.item.updatedAt!)
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
    performSegueWithIdentifier("userTimelineSegue", sender: itemCell.item.user)
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

