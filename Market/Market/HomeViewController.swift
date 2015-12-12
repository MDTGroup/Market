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
  
  //var items = [Item]()
  var posts = [Post]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    tableView.dataSource = self
    tableView.delegate = self
    
    // Refresh control
    //    refreshControl.tintColor = UIColor.whiteColor()
    refreshControl.addTarget(self, action: Selector("loadData"), forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshControl)
    
    // Add the activity Indicator for table footer for infinity load
    let tableFooterView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
    loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    loadingView.center = tableFooterView.center
    loadingView.hidesWhenStopped = true
    tableFooterView.addSubview(loadingView)
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    loadData()
  }
  
  func loadData() {
    var params = [String : AnyObject]()
    params["lastUpdatedAt"] = nil

    Post.getNewsfeed(NewsfeedType.Newest, params: params) { (posts, error) -> Void in
      if let posts = posts {
        self.posts = posts
        self.tableView.reloadData()
        
        self.refreshControl.endRefreshing()
        self.loadingView.stopAnimating()
        self.isLoadingNextPage = false
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
      } else {
        print(error)
        
        self.refreshControl.endRefreshing()
        self.loadingView.stopAnimating()
        self.isLoadingNextPage = false
        MBProgressHUD.hideHUDForView(self.view, animated: true)
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "detailSegue") {
      let detailVC: DetailViewController = segue.destinationViewController as! DetailViewController
      let data = sender as! Post
      detailVC.post = data
    }
  }
  
}

extension NSDate {
  func dayBefore(nDays: Int) -> NSDate {
    let oneDay:Double = 60 * 60 * 24
    return self.dateByAddingTimeInterval(-oneDay * Double(nDays))
  }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource, ItemCellDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath) as! ItemCell
    cell.item = posts[indexPath.row]
    cell.delegate = self
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // Perform segue
    let item = posts[indexPath.row]
    
    performSegueWithIdentifier("detailSegue", sender: item)
  }
}
