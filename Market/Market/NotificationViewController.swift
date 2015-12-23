//
//  NotificationViewController.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/18/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import MBProgressHUD

class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl = UIRefreshControl()
    var loadingView: UIActivityIndicatorView!
    var isLoadingNextPage = false
    var isEndOfFeed = false
    var noMoreResultLabel = UILabel()
    
    var notifications = [Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading notifications..."
        
        loadNewestData()
    }
    
    func initControls() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // Refresh control
        refreshControl.addTarget(self, action: Selector("loadNewestData"), forControlEvents: UIControlEvents.ValueChanged)
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
    }
    
    func loadNewestData() {
        notifications = []
        loadData(nil)
    }
    
    func loadData(lastUpdatedAt: NSDate?) {
        if let currentUser = User.currentUser() {
            currentUser.getNotifications(lastUpdatedAt, callback: { (notifications, error) -> Void in
                guard error == nil else {
                    print(error)
                    self.isEndOfFeed = true
                    return
                }
                
                if let notifications = notifications {
                    if notifications.count == 0 {
                        self.isEndOfFeed = true
                    } else {
                        self.notifications.appendContentsOf(notifications)
                        self.tableView.reloadData()
                    }
                    self.isLoadingNextPage = false
                    MBProgressHUD.hideHUDForView(self.view, animated: true)

                    self.noMoreResultLabel.hidden = !self.isEndOfFeed
                    self.refreshControl.endRefreshing()
                    self.loadingView.stopAnimating()
                }
            })
        }
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationTableViewCell", forIndexPath: indexPath) as! NotificationTableViewCell
        cell.notification = notifications[indexPath.row]
        // Infinite load if last cell
        if !isLoadingNextPage && !isEndOfFeed {
            if indexPath.row == notifications.count - 1 {
                loadingView.startAnimating()
                isLoadingNextPage = true
                loadData(notifications[indexPath.row].createdAt!)
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = DetailViewController.instantiateViewController
        let notification = notifications[indexPath.row]
        notification.markRead()
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        vc.post = notification.post
        presentViewController(vc, animated: true, completion: nil)
        
    }
}