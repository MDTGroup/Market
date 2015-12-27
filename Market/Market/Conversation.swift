//
//  Conversation.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/13/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
import Parse

class Conversation: PFObject, PFSubclassing {
    static func parseClassName() -> String {
        return "Conversation"
    }
    
    @NSManaged var userIds: [String]
    @NSManaged var usersChooseHideConversation: [User]
    @NSManaged var readUsers: [String]
    @NSManaged var post: Post
    @NSManaged var lastMessage: Message?
    var messages: PFRelation! {
        return relationForKey("messages")
    }
    
    var toUser: User?
    
    func markRead(callback: PFBooleanResultBlock) {
        if let currentUser = User.currentUser(), userObjectId = currentUser.objectId {
            if !readUsers.contains(userObjectId) {
                var params = [String : AnyObject]()
                params["id"] = objectId!
                PFCloud.callFunctionInBackground("conversation_markRead", withParameters: params) { (result, error) -> Void in
                    guard error == nil else {
                        print(error)
                        callback(false, nil)
                        return
                    }
                    callback(true, nil)
                }
            }
        }
    }
    
    func getMessages(lastCreatedAt: NSDate?, maxResultPerRequest: Int, callback: MessageResultBlock) {
        let query = messages.query()
        query.selectKeys(["user", "text", "photo", "video", "location"])
        query.includeKey("user")
        query.limit = maxResultPerRequest
        
        if let lastCreatedAt = lastCreatedAt {
            query.whereKey("createdAt", greaterThan: lastCreatedAt)
        }
        query.orderByDescending("createdAt")
        query.cachePolicy = .NetworkElseCache
        query.findObjectsInBackgroundWithBlock { (pfObjs, error) -> Void in
            guard error == nil else {
                callback(messages: nil, error: error)
                return
            }
            if let messages = pfObjs as? [Message] {
                callback(messages: messages.reverse(), error: nil)
            }
        }
    }
    
    func getEarlierMessages(createdAt: NSDate?, callback: MessageResultBlock) {
        let query = messages.query()
        query.selectKeys(["user", "text", "photo", "video", "location"])
        query.includeKey("user")
        query.limit = 5
        if let createdAt = createdAt {
            query.whereKey("createdAt", lessThan: createdAt)
        }
        query.orderByDescending("createdAt")
        query.cachePolicy = .NetworkElseCache
        query.findObjectsInBackgroundWithBlock { (pfObjs, error) -> Void in
            guard error == nil else {
                callback(messages: nil, error: error)
                return
            }
            if let messages = pfObjs as? [Message] {
                callback(messages: messages.reverse(), error: nil)
            }
        }
    }
    
    func addMessage(currentUser: User, text: String, videoFile: PFFile?, photoFile: PFFile?, location: PFGeoPoint?, callback: PFBooleanResultBlock) {
        if text.isEmpty {
            return
        }
        let message = Message()
        message.user = currentUser
        message.text = text
        message.video = videoFile
        message.photo = photoFile
        message.location = location
        message.conversation = self
        message.saveInBackgroundWithBlock { (success, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            if success {
                self.messages.addObject(message)
                for userId in self.userIds where userId !=  currentUser.objectId {
                    message.sendPushNotification(userId, postId: self.post.objectId!, text: text, video: videoFile, photo: photoFile, location: location)
                }
                self.readUsers = [currentUser.objectId!]
                self.lastMessage = message
                self.saveInBackgroundWithBlock(callback)
            }
        }
    }
    
    static func addConversation(fromUser: User, toUser: User, post: Post, callback: ConversationResultBlock) {
        if fromUser.objectId == toUser.objectId {
            return
        }
        if let query = Conversation.query() {
            let userIds = [fromUser.objectId!, toUser.objectId!]
            query.selectKeys(["post", "userIds", "readUsers"])
            query.includeKey("post")
            query.whereKey("post", equalTo: post)
            query.whereKey("userIds", containsAllObjectsInArray: userIds)
            query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                if let conversations = results as? [Conversation] {
                    if conversations.count == 0 {
                        let conversation = Conversation()
                        conversation.userIds = userIds
                        conversation.readUsers = [fromUser.objectId!]
                        conversation.usersChooseHideConversation = []
                        conversation.post = post
                        let acl = PFACL()
                        acl.setWriteAccess(true, forUser: fromUser)
                        acl.setWriteAccess(true, forUser: toUser)
                        acl.setReadAccess(true, forUser: fromUser)
                        acl.setReadAccess(true, forUser: toUser)
                        conversation.ACL = acl
                        conversation.saveInBackgroundWithBlock({ (success, error) -> Void in
                            guard error == nil else {
                                callback(conversation: nil, error: error)
                                return
                            }
                            conversation.post.fetchIfNeededInBackgroundWithBlock({ (post, error) -> Void in
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    callback(conversation: conversation, error: nil)
                                })
                            })
                        })
                    } else if conversations.count == 1 {
                        let conversation = conversations[0]
                        conversation.usersChooseHideConversation = []
                        callback(conversation: conversation, error: nil)
                    } else {
                        print("Something wrong! A conversation for a post should only have 2 users")
                    }
                }
            })
        }
    }
    
    static func getConversations(forNetworkOnly: Bool, lastUpdatedAt: NSDate?, callback: ConversationsResultBlock) {
        if let query = Conversation.query(), currentUser = User.currentUser() {
            var cachePolicy = PFCachePolicy.CacheThenNetwork
            if forNetworkOnly {
                cachePolicy = .NetworkOnly
            }
            
            query.selectKeys(["post", "userIds", "readUsers", "lastMessage"])
            query.includeKey("lastMessage")
            query.includeKey("post")
            query.includeKey("post.user")
            query.whereKey("userIds", equalTo: currentUser.objectId!)
            query.whereKey("usersChooseHideConversation", notEqualTo: currentUser.objectId!)
            query.whereKeyExists("lastMessage")
            if let lastUpdatedAt = lastUpdatedAt {
                query.whereKey("updatedAt", greaterThan: lastUpdatedAt)
            }
            query.orderByDescending("updatedAt")
            query.cachePolicy = cachePolicy
            query.findObjectsInBackgroundWithBlock({ (pfObjs, error) -> Void in
                guard error == nil else {
                    callback(conversations: nil, error: error)
                    return
                }
                if let conversations = pfObjs as? [Conversation] {
                    
                    var listUserIds = [String]()
                    for conversation in conversations {
                        for userId in conversation.userIds where userId != currentUser.objectId! {
                            if !listUserIds.contains(userId) {
                                listUserIds.append(userId)
                            }
                        }
                    }
                    
                    if let userQuery = User.query() {
                        userQuery.selectKeys(["fullName", "avatar"])
                        userQuery.whereKey("objectId", containedIn: listUserIds)
                        userQuery.cachePolicy = cachePolicy
                        userQuery.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
                            guard error == nil else {
                                callback(conversations: nil, error: error)
                                return
                            }
                            if let users = users as? [User] {
                                for conversation in conversations {
                                    for user in users where conversation.userIds.contains(user.objectId!) {
                                        conversation.toUser = user
                                    }
                                }
                            }
                            
                            callback(conversations: conversations, error: nil)
                        })
                    }
                }
            })
        }
    }
    
    static func getConversationsByPost(post:Post, lastUpdatedAt: NSDate?, callback: ConversationsResultBlock) {
        if let query = Conversation.query(), currentUser = User.currentUser() {
            let cachePolicy = PFCachePolicy.CacheThenNetwork
            QueryUtils.bindQueryParamsForInfiniteLoading(query, lastUpdatedAt: lastUpdatedAt)
            query.selectKeys(["userIds", "readUsers", "lastMessage"])
            query.includeKey("lastMessage")
            query.whereKey("post", equalTo: post)
            query.whereKey("userIds", equalTo: currentUser.objectId!)
            query.whereKey("usersChooseHideConversation", notEqualTo: currentUser.objectId!)
            query.whereKeyExists("lastMessage")
            query.cachePolicy = cachePolicy
            query.findObjectsInBackgroundWithBlock({ (pfObjs, error) -> Void in
                guard error == nil else {
                    callback(conversations: nil, error: error)
                    return
                }
                if let conversations = pfObjs as? [Conversation] {
                    
                    var listUserIds = [String]()
                    for conversation in conversations {
                        for userId in conversation.userIds where userId != currentUser.objectId! {
                            if !listUserIds.contains(userId) {
                                listUserIds.append(userId)
                            }
                        }
                    }
                    
                    if let userQuery = User.query() {
                        userQuery.selectKeys(["fullName", "avatar"])
                        userQuery.whereKey("objectId", containedIn: listUserIds)
                        userQuery.cachePolicy = cachePolicy
                        userQuery.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
                            guard error == nil else {
                                callback(conversations: nil, error: error)
                                return
                            }
                            if let users = users as? [User] {
                                for conversation in conversations {
                                    for user in users where conversation.userIds.contains(user.objectId!) {
                                        conversation.toUser = user
                                    }
                                }
                            }
                            
                            callback(conversations: conversations, error: nil)
                        })
                    }
                }
            })
        }
    }
    
    static func getConversationsByPostForRefreshingData(post:Post, lastUpdatedAt: NSDate?, callback: ConversationsResultBlock) {
        if let query = Conversation.query(), currentUser = User.currentUser() {
            query.selectKeys(["userIds", "readUsers", "lastMessage"])
            query.includeKey("lastMessage")
            query.whereKey("post", equalTo: post)
            query.whereKey("userIds", equalTo: currentUser.objectId!)
            query.whereKey("usersChooseHideConversation", notEqualTo: currentUser.objectId!)
            query.whereKeyExists("lastMessage")
            if let lastUpdatedAt = lastUpdatedAt {
                query.whereKey("updatedAt", greaterThan: lastUpdatedAt)
            }
            query.orderByDescending("updatedAt")
            query.cachePolicy = .NetworkOnly
            query.findObjectsInBackgroundWithBlock({ (pfObjs, error) -> Void in
                guard error == nil else {
                    callback(conversations: nil, error: error)
                    return
                }
                if let conversations = pfObjs as? [Conversation] {
                    
                    var listUserIds = [String]()
                    for conversation in conversations {
                        for userId in conversation.userIds where userId != currentUser.objectId! {
                            if !listUserIds.contains(userId) {
                                listUserIds.append(userId)
                            }
                        }
                    }
                    
                    if let userQuery = User.query() {
                        userQuery.selectKeys(["fullName", "avatar"])
                        userQuery.whereKey("objectId", containedIn: listUserIds)
                        userQuery.cachePolicy = .NetworkOnly
                        userQuery.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
                            guard error == nil else {
                                callback(conversations: nil, error: error)
                                return
                            }
                            if let users = users as? [User] {
                                for conversation in conversations {
                                    for user in users where conversation.userIds.contains(user.objectId!) {
                                        conversation.toUser = user
                                    }
                                }
                            }
                            
                            callback(conversations: conversations, error: nil)
                        })
                    }
                }
            })
        }
    }
    
    static func countUnread(callback: PFIntegerResultBlock) {
        if let query = Conversation.query(), currentUser = User.currentUser() {
            query.whereKey("userIds", equalTo: currentUser.objectId!)
            query.whereKey("readUsers", notEqualTo: currentUser.objectId!)
            query.whereKeyExists("lastMessage")
            query.countObjectsInBackgroundWithBlock(callback)
        }
    }
}