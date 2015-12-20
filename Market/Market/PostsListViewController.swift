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
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl = UIRefreshControl()
    var loadingView: UIActivityIndicatorView!
    var isLoadingNextPage = false
    var isEndOfFeed = false
    var noMoreResultLabel = UILabel()
    
    var conversations = [Conversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadNewestData()
        
    }
    
    func loadNewestData() {
        conversations = []
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
                }
                self.conversations.appendContentsOf(conversations)
                self.filterDuplicatePost()
                self.tableView.reloadData()
            }
            
            self.noMoreResultLabel.hidden = !self.isEndOfFeed
            self.refreshControl.endRefreshing()
            self.loadingView.stopAnimating()
            self.isLoadingNextPage = false
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let messageVC = segue.destinationViewController as? MessageViewController {
            messageVC.conversations = conversations
        }
    }
    
    func filterDuplicatePost() {
        var posts = [String]()
        var newConversations = [Conversation]()
        for conversation in conversations.reverse() {
            if posts.contains(conversation.post.objectId!) {
                continue
            }
            posts.append(conversation.post.objectId!)
            print(conversation.post.objectId!)
            newConversations.append(conversation)
        }
        conversations = newConversations
    }
}

extension PostsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemListCell", forIndexPath: indexPath) as! ItemListCell

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
}