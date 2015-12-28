//
//  PostsListViewController.swift
//  Market
//
//  Created by Dinh Thi Minh on 12/18/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

class PostsListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var timer = NSTimer()
    var refreshControl = UIRefreshControl()
    
    var filteredConversationsByPost = [Conversation]()
    var conversations = [Conversation]()
    var countMessages = [String : (unread: Int, total: Int)]()
    var sections = [(title: "Buying", conversation: [Conversation]()), (title: "Selling", conversation: [Conversation]())]
    var tableFooterView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initControls()
        
        let strToBold = "Posts"
        let message = "Loading \(strToBold)..."
        refreshControl.attributedTitle = message.bold(strToBold)
        
        loadData(false, lastUpdatedAt: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(3.5, target: self, selector: "refreshData", userInfo: nil, repeats: true)
        if filteredConversationsByPost.count > 0 {
            refreshData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    func initControls() {
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.hidden = false
        refreshControl.beginRefreshing()
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableFooterView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
        let noMessageLabel = UILabel()
        noMessageLabel.frame = tableFooterView.frame
        noMessageLabel.textAlignment = NSTextAlignment.Center
        noMessageLabel.font = UIFont.systemFontOfSize(12.0)
        noMessageLabel.textColor = UIColor.grayColor()
        noMessageLabel.text = "No messages"
        tableFooterView.insertSubview(noMessageLabel, atIndex: 0)
    }
    
    func loadData(forNetworkOnly: Bool, lastUpdatedAt: NSDate?) {
        Conversation.getConversations(forNetworkOnly, lastUpdatedAt: lastUpdatedAt) { (newConversations, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            if let newConversations = newConversations {
                if newConversations.count == 0 {
                    
                } else {
                    
                    if self.conversations.count == 0 {
                        self.conversations.appendContentsOf(newConversations)
                    } else {
                        for newConversation in newConversations {
                            var found = false
                            for (index, conversation) in self.conversations.enumerate() {
                                if newConversation.objectId == conversation.objectId {
                                    self.conversations.removeAtIndex(index)
                                    self.conversations.insert(newConversation, atIndex: 0)
                                    found = true
                                    break
                                }
                            }
    
                            if !found {
                                self.conversations.insert(newConversation, atIndex: 0)
                            }
                        }
                    }
                    self.filterDuplicatePost()
                    self.tableView.reloadData()
                    
                    if forNetworkOnly && !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
                        TabBarController.instance.onRefreshMessageBadge(nil)
                    }
                }
            }
            
            if self.filteredConversationsByPost.count == 0 {
                self.tableView.tableFooterView = self.tableFooterView
                self.tableView.tableFooterView?.hidden = true
            } else {
                self.tableView.tableFooterView = UIView(frame: CGRect.zero)
                self.tableView.tableFooterView?.hidden = true
            }

            self.refreshControl.endRefreshing()
            self.refreshControl.removeFromSuperview()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let messageVC = segue.destinationViewController as? MessageViewController {
            if let cell = sender as? ItemListCell {
                let post = cell.conversation.post
                var conversationsByPost = conversations.filter({ (conversation) -> Bool in
                    return conversation.post.objectId == post.objectId
                })
                conversationsByPost = conversationsByPost.sort { (a, b) -> Bool in
                    return a.updatedAt!.compare(b.updatedAt!).rawValue > 0
                }
                messageVC.post = post
                messageVC.title = post.title
                messageVC.conversations = conversationsByPost
            }
        } else if let chatVC = segue.destinationViewController as? ParentChatViewController {
            if let conversation = sender as?  Conversation {
                chatVC.conversation = conversation
                if let toUser = conversation.toUser {
                    chatVC.title = toUser.fullName
                }
            }
        }
    }
    
    func filterDuplicatePost() {
        var posts = [String]()
        var newConversations = [Conversation]()
        if let currentUser = User.currentUser() {
            let currentUserId = currentUser.objectId!
            countMessages.removeAll()
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
        }
        filteredConversationsByPost = newConversations.sort { (a, b) -> Bool in
            return a.updatedAt!.compare(b.updatedAt!).rawValue > 0
        }
        sections[0].conversation = filteredConversationsByPost.filter({ (conversation) -> Bool in
            return conversation.post.user.objectId != User.currentUser()?.objectId
        })
        sections[1].conversation = filteredConversationsByPost.filter({ (conversation) -> Bool in
            return conversation.post.user.objectId == User.currentUser()?.objectId
        })
    }
    
    
    func refreshData() {
        let updatedAt = filteredConversationsByPost.count > 0 ? filteredConversationsByPost[0].updatedAt : nil
        loadData(true, lastUpdatedAt: updatedAt)
    }
}

extension PostsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if filteredConversationsByPost.count == 0 {
            return 0
        }
        return sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections[section].conversation.count == 0 {
            return ""
        }
        return sections[section].title
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].conversation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemListCell", forIndexPath: indexPath) as! ItemListCell
        
        let conversation = sections[indexPath.section].conversation[indexPath.row]
        if let tupleCount = countMessages[conversation.post.objectId!] {
            cell.countMessages = tupleCount
        }
        cell.conversation = conversation
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let conversation = sections[indexPath.section].conversation[indexPath.row]
        if  conversation.post.user.objectId != User.currentUser()!.objectId {
            performSegueWithIdentifier("segueChat", sender: conversation)
        } else {
            performSegueWithIdentifier("segueMessage", sender: tableView.cellForRowAtIndexPath(indexPath))
        }
    }
}