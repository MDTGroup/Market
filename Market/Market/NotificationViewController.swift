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
    let homeSB = UIStoryboard(name: "Home", bundle: nil)
    var notifications = [Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
        loadData(nil)
    }
    
    func initControls() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadData(lastUpdatedAt: NSDate?) {
        User.currentUser()?.getNotifications(lastUpdatedAt, callback: { (notifications, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            
            if let notifications = notifications {
                self.notifications.appendContentsOf(notifications)
                self.tableView.reloadData()
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailVC = segue.destinationViewController as? DetailViewController, cell = sender as? NotificationTableViewCell {
            if let indexPath = tableView.indexPathForCell(cell) {
                detailVC.post = notifications[indexPath.row].post
            }
        }
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationTableViewCell", forIndexPath: indexPath) as! NotificationTableViewCell
        cell.post = notifications[indexPath.row].post
        cell.textLabel!.text = String(notifications[indexPath.row].type)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.homeSB.instantiateViewControllerWithIdentifier("postDetail")
    }
}