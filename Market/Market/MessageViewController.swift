//
//  MessageViewController.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/17/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl = UIRefreshControl()
    var loadingView: UIActivityIndicatorView!
    var isLoadingNextPage = false
    var isEndOfFeed = false
    var noMoreResultLabel = UILabel()
    
    var conversations = [Conversation]()
    var post: Post!
    
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initControls()
        
        refreshControl.hidden = false
        refreshControl.beginRefreshing()
        
        let strToBold = "Messages"
        let message = "Loading \(strToBold)..."
        refreshControl.attributedTitle = message.bold(strToBold)
        
        if conversations.count > 0 {
            isLoadingNextPage = true
            self.noMoreResultLabel.text = (self.conversations.count > 0) ? "No more result" : "No messages"
            self.noMoreResultLabel.hidden = conversations.count > 12
            self.refreshControl.endRefreshing()
            self.loadingView.stopAnimating()
        } else if PostsListViewController.needToRefresh == false {
            loadNewestData()
        }   
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if PostsListViewController.needToRefresh {
            loadNewestData()
            PostsListViewController.needToRefresh = false
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(3.5, target: self, selector: "refreshData", userInfo: nil, repeats: true)
        refreshData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        refreshControl.endRefreshing()
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
        noMoreResultLabel.textAlignment = NSTextAlignment.Center
        noMoreResultLabel.font = UIFont.systemFontOfSize(12.0)
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
        Conversation.getConversationsByPost(post, lastUpdatedAt: lastUpdatedAt) { (newConversations, error) -> Void in
            guard error == nil else {
                print(error)
                self.isEndOfFeed = true
                return
            }
            if let newConversations = newConversations {
                if newConversations.count == 0 {
                    self.isEndOfFeed = true
                } else {
                    if self.conversations.count == 0 {
                        self.conversations.appendContentsOf(newConversations)
                    } else {
                        for newConversation in newConversations {
                            var found = false
                            for (index, conversation) in self.conversations.enumerate() {
                                if newConversation.objectId == conversation.objectId {
                                    self.conversations[index] = newConversation
                                    found = true
                                    break
                                }
                            }
                            if !found {
                                self.conversations.append(newConversation)
                            }
                        }
                    }
                    
                    self.tableView.reloadData()
                }
            }
            
            self.noMoreResultLabel.hidden = !self.isEndOfFeed
            self.noMoreResultLabel.text = (self.isEndOfFeed && self.conversations.count > 0) ? "No more result" : "No messages"
            
            self.refreshControl.endRefreshing()
            self.loadingView.stopAnimating()
            self.isLoadingNextPage = false
        }
    }
    
    func refreshData() {
        if conversations.count == 0 {
            return
        }
        Conversation.getConversationsByPost(post, lastUpdatedAt: nil) { (newConversations, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            if let newConversations = newConversations {
                if newConversations.count == 0 {
                    return
                } else {
                    for newConversation in newConversations {
                        var found = false
                        for (index, conversation) in self.conversations.enumerate() {
                            if newConversation.objectId == conversation.objectId {
                                self.conversations[index] = newConversation
                                found = true
                                break
                            }
                        }
                        if !found {
                            self.conversations.append(newConversation)
                        }
                    }
                    
                    self.conversations = self.conversations.sort { (a, b) -> Bool in
                        return a.updatedAt!.compare(b.updatedAt!).rawValue > 0
                    }
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let chatVC = segue.destinationViewController as? ParentChatViewController,
            cell = sender as? MessageCell {
                if let indexPath = tableView.indexPathForCell(cell) {
                    let conversation = conversations[indexPath.row]
                    conversation.post = post
                    chatVC.conversation = conversation
                    if let toUser = conversation.toUser {
                        chatVC.title = toUser.fullName
                    }
                }
        }
    }
}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if conversations.count == 0 {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
        
        cell.conversation = conversations[indexPath.row]
        
        // Infinite load if last cell
        if !isLoadingNextPage && !isEndOfFeed {
            if indexPath.row == conversations.count - 1 {
                loadingView.startAnimating()
                isLoadingNextPage = true
                loadData(conversations[indexPath.row].updatedAt!)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath((indexPath), animated: true)
    }
}