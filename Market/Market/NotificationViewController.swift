//
//  NotificationViewController.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/18/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl = UIRefreshControl()
    var loadingView: UIActivityIndicatorView!
    var isLoadingNextPage = false
    var isEndOfFeed = false
    var noMoreResultLabel = UILabel()
    
    var notifications = [Notification]()
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
        
        refreshControl.hidden = false
        refreshControl.beginRefreshing()
        
        let strToBold = "Notifications"
        let message = "Loading \(strToBold)..."
        refreshControl.attributedTitle = message.bold(strToBold)
        
        loadData(nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(3.5, target: self, selector: "refreshData", userInfo: nil, repeats: true)
        if notifications.count > 0 {
            refreshData()
        }
    }
    
    func initControls() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // Refresh control
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Add the activity Indicator for table footer for infinity load
        let tableFooterView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
        loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingView.center = tableFooterView.center
        loadingView.hidesWhenStopped = true
        tableFooterView.insertSubview(loadingView, atIndex: 0)
        
        // Initialize the noMoreResult
        noMoreResultLabel.frame = tableFooterView.frame
        noMoreResultLabel.textAlignment = NSTextAlignment.Center
        noMoreResultLabel.font = UIFont.systemFontOfSize(12.0)
        noMoreResultLabel.textColor = UIColor.grayColor()
        noMoreResultLabel.hidden = true
        tableFooterView.insertSubview(noMoreResultLabel, atIndex: 0)
        tableView.tableFooterView = tableFooterView
    }
    
    func loadData(lastUpdatedAt: NSDate?) {
        if let currentUser = User.currentUser() {
            currentUser.getNotifications(lastUpdatedAt, callback: { (newNotifications, error) -> Void in
                guard error == nil else {
                    print(error)
                    self.isEndOfFeed = true
                    return
                }
                
                if let newNotifications = newNotifications {
                    if newNotifications.count == 0 {
                        self.isEndOfFeed = true
                    } else {
                        if self.notifications.count == 0 {
                            self.notifications.appendContentsOf(newNotifications)
                        } else {
                            for newNotification in newNotifications {
                                var found = false
                                for (index, notification) in self.notifications.enumerate() {
                                    if newNotification.objectId == notification.objectId {
                                        self.notifications[index] = newNotification
                                        found = true
                                        break
                                    }
                                }
                                if !found {
                                    self.notifications.append(newNotification)
                                }
                            }
                        }
                        self.tableView.reloadData()
                    }
                    
                    self.noMoreResultLabel.hidden = !self.isEndOfFeed
                    self.noMoreResultLabel.text = (self.isEndOfFeed && self.notifications.count > 0) ? "No more result" : "No notifications"
                    
                    self.loadingView.stopAnimating()
                    self.isLoadingNextPage = false
                }
                self.refreshControl.endRefreshing()
                self.refreshControl.removeFromSuperview()
            })
        }
    }
    
    func refreshData() {
        if let currentUser = User.currentUser() {
            let createdAt = notifications.count > 0 ? notifications[0].createdAt : nil
            currentUser.getNotificationsForRefreshingData(createdAt, callback: { (notifications, error) -> Void in
                guard error == nil else {
                    print(error)
                    return
                }
                if let newNotifications = notifications {
                    if newNotifications.count == 0 {
                        return
                    } else {
                        var hasNewItem = false
                        for newNotification in newNotifications {
                            var found = false
                            for (index, notification) in self.notifications.enumerate() {
                                if newNotification.objectId == notification.objectId {
                                    self.notifications.removeAtIndex(index)
                                    self.notifications.insert(newNotification, atIndex: 0)
                                    found = true
                                    break
                                }
                            }
                            if !found {
                                self.notifications.insert(newNotification, atIndex: 0)
                                hasNewItem = true
                            }
                        }
                        
                        
                        if hasNewItem && UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
                            TabBarController.instance.onRefreshNotificationBadge(nil)
                        }
                        
                        self.notifications = self.notifications.sort { (a, b) -> Bool in
                            return a.createdAt!.compare(b.createdAt!).rawValue > 0
                        }
                        self.tableView.reloadData()
                    }
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
        
        TabBarController.instance.onRefreshNotificationBadge(nil)
        
    }
}