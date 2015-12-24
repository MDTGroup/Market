//
//  PostsListViewController.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/18/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import MBProgressHUD

class PostsListViewController: UIViewController {
    static var needToRefresh = false
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl = UIRefreshControl()
    var loadingView: UIActivityIndicatorView!
    var isLoadingNextPage = false
    var isEndOfFeed = false
    var noMoreResultLabel = UILabel()
    
    var filteredConversationsByPost = [Conversation]()
    var conversations = [Conversation]()
    var countMessages = [String : (unread: Int, total: Int)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initControls()
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading posts..."

        if PostsListViewController.needToRefresh == false {
            loadNewestData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if PostsListViewController.needToRefresh {
            loadNewestData()
            PostsListViewController.needToRefresh = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MBProgressHUD.hideHUDForView(self.view, animated: true)
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
        noMoreResultLabel.font = UIFont(name: noMoreResultLabel.font.fontName, size: 15)
        noMoreResultLabel.textColor = UIColor.grayColor()
        noMoreResultLabel.hidden = true
        tableFooterView.addSubview(noMoreResultLabel)
        tableView.tableFooterView = tableFooterView
    }
    
    func loadNewestData() {
        conversations = []
        countMessages.removeAll()
        loadData(nil)
    }
    
    func loadData(lastUpdatedAt: NSDate?) {
        Conversation.getConversations(lastUpdatedAt) { (conversations, error) -> Void in
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
                    self.filterDuplicatePost()
                    self.tableView.reloadData()
                }
            }
            
            self.noMoreResultLabel.hidden = !self.isEndOfFeed
            self.noMoreResultLabel.text = (self.isEndOfFeed && self.conversations.count > 0) ? "No more result" : "No messages"

            self.refreshControl.endRefreshing()
            self.loadingView.stopAnimating()
            self.isLoadingNextPage = false
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let messageVC = segue.destinationViewController as? MessageViewController {
            if let cell = sender as? ItemListCell {
                let post = cell.conversation.post
                var conversationsByPost = [Conversation]()
                for conversation in conversations {
                    if conversation.post.objectId == post.objectId {
                        conversationsByPost.append(conversation)
                    }
                }
                messageVC.post = post
                messageVC.conversations = conversationsByPost
            }
        }
    }
    
    func filterDuplicatePost() {
        var posts = [String]()
        var newConversations = [Conversation]()
        let currentUserId = User.currentUser()!.objectId!
        for conversation in conversations.reverse() {
            let id = conversation.post.objectId!
            if countMessages[id] == nil {
                countMessages[id] = (0,0)
            }
            if var tupleCount = countMessages[id] {
                if !conversation.readUsers.contains(currentUserId) {
                    tupleCount.unread += 1
                }
                tupleCount.total += 1
                countMessages[id] = tupleCount
            }
            
            if posts.contains(id) {
                continue
            }
            posts.append(conversation.post.objectId!)
            newConversations.append(conversation)
        }
        filteredConversationsByPost = newConversations.reverse()
    }
}

extension PostsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredConversationsByPost.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemListCell", forIndexPath: indexPath) as! ItemListCell
        
        let conversation = filteredConversationsByPost[indexPath.row]
        if let tupleCount = countMessages[conversation.post.objectId!] {
            cell.countMessages = tupleCount
        }
        cell.conversation = conversation
        
        // Infinite load if last cell
        if !isLoadingNextPage && !isEndOfFeed {
            if indexPath.row == filteredConversationsByPost.count - 1 {
                loadingView.startAnimating()
                isLoadingNextPage = true
                loadData(filteredConversationsByPost[indexPath.row].updatedAt!)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}