//
//  MessageViewController.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/17/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import MBProgressHUD

class MessageViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl = UIRefreshControl()
    var loadingView: UIActivityIndicatorView!
    var isLoadingNextPage = false
    var isEndOfFeed = false
    var noMoreResultLabel = UILabel()
    
    var conversations = [Conversation]()
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initControls()
        
        if conversations.count > 0 {
            title =  conversations[0].post.title
        }
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading messages..."
        
        if conversations.count == 0 {
            loadNewestData()
        } else {
            isLoadingNextPage = true
            self.noMoreResultLabel.hidden = !self.isEndOfFeed
            self.refreshControl.endRefreshing()
            self.loadingView.stopAnimating()
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }   
    }
    
    func initControls() {
        tableView.dataSource = self
        tableView.delegate = self
        
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
        tableFooterView.addSubview(noMoreResultLabel)
        tableView.tableFooterView = tableFooterView
    }
    
    func loadNewestData() {
        conversations = []
        loadData(nil)
    }
    
    func loadData(lastUpdatedAt: NSDate?) {
        if post == nil {
            return
        }
        Conversation.getConversationsByPost(post, lastUpdatedAt: lastUpdatedAt) { (conversations, error) -> Void in
            guard error == nil else {
                print(error)
                self.isEndOfFeed = true
                return
            }
            if let conversations = conversations {
                if conversations.count == 0 {
                    self.isEndOfFeed = true
                } else {
                    self.conversations.appendContentsOf(conversations)
                    self.tableView.reloadData()
                }
            }
            
            if self.conversations.count > 0 {
                self.title =  self.conversations[0].post.title
            }
            
            self.noMoreResultLabel.hidden = !self.isEndOfFeed
            self.refreshControl.endRefreshing()
            self.loadingView.stopAnimating()
            self.isLoadingNextPage = false
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let chatVC = segue.destinationViewController as? ParentChatViewController,
            cell = sender as? MessageCell {
                if let indexPath = tableView.indexPathForCell(cell) {
                    chatVC.conversation = conversations[indexPath.row]
                }
        }
    }
}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
        
        cell.conversation = conversations[indexPath.row]
        
        // Infinite load if last cell
        if !isLoadingNextPage && !isEndOfFeed {
            if indexPath.row == conversations.count - 1 {
                loadingView.startAnimating()
                isLoadingNextPage = true
                loadData(conversations[indexPath.row].createdAt!)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath((indexPath), animated: true)
        
        let conversation = conversations[indexPath.row]
        conversation.markRead()
    }
}