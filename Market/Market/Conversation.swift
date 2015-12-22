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
    
    @NSManaged var users: [User]
    @NSManaged var usersChooseHideConversation: [User]
    @NSManaged var readUsers: [String]
    @NSManaged var post: Post
    @NSManaged var messages: PFRelation
    
    func markRead() {
        if let currentUser = User.currentUser(), userObjectId = currentUser.objectId {
            if !readUsers.contains(userObjectId) {
                readUsers.append(userObjectId)
                var params = [String : AnyObject]()
                params["id"] = objectId!
                PFCloud.callFunctionInBackground("conversation_markRead", withParameters: params) { (result, error) -> Void in
                    guard error == nil else {
                        print(error)
                        return
                    }
                }
            }
        }
    }
    
    func getMessages(lastCreatedAt: NSDate?, callback: MessageResultBlock) {
        let query = messages.query()
        query.includeKey("user")
        QueryUtils.bindQueryParamsForInfiniteLoadingForChat(query, lastCreatedAt: lastCreatedAt)
        query.findObjectsInBackgroundWithBlock { (pfObjs, error) -> Void in
            guard error == nil else {
                callback(messages: nil, error: error)
                return
            }
            if let messages = pfObjs as? [Message] {
                callback(messages: messages, error: nil)
            }
        }
    }
    
    func addMessage(currentUser: User, text: String, callback: PFBooleanResultBlock) {
        let message = Message()
        message.user = currentUser
        message.text = text
        message.conversation = self
        message.saveInBackgroundWithBlock { (success, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            if success {
                self.messages.addObject(message)
                self.saveInBackgroundWithBlock(callback)
            }
        }
    }
    
    static func addConversation(toUser: User, post: Post, callback: ConversationResultBlock) {
        if let currentUser = User.currentUser() {
            if currentUser.objectId == toUser.objectId {
                return
            }
            if let query = Conversation.query() {
                let users = [currentUser, toUser]
                query.includeKey("post")
                query.whereKey("post", equalTo: post)
                query.whereKey("users", containsAllObjectsInArray: users)
                query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                    if let conversations = results as? [Conversation] {
                        if conversations.count == 0 {
                            let conversation = Conversation()
                            conversation.users = users
                            conversation.usersChooseHideConversation = []
                            conversation.post = post
                            let acl = PFACL()
                            acl.setWriteAccess(true, forUser: currentUser)
                            acl.setWriteAccess(true, forUser: toUser)
                            acl.setReadAccess(true, forUser: currentUser)
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
                            print("Why? Conversations should only have one with these post")
                        }
                    }
                })
            }
        }
    }
    
    static func getConversations(lastUpdatedAt: NSDate?, callback: ConversationsResultBlock) {
        if let query = Conversation.query(), currentUser = User.currentUser() {
            QueryUtils.bindQueryParamsForInfiniteLoading(query, lastUpdatedAt: lastUpdatedAt)
            query.includeKey("post")
            query.includeKey("users")
            query.whereKey("users", equalTo: currentUser)
            query.whereKey("usersChooseHideConversation", notEqualTo: currentUser)
            query.findObjectsInBackgroundWithBlock({ (pfObjs, error) -> Void in
                guard error == nil else {
                    callback(conversations: nil, error: error)
                    return
                }
                if let conversations = pfObjs as? [Conversation] {
                    callback(conversations: conversations, error: nil)
                }
            })
        }
    }
    
    static func getConversationsByPost(post:Post, lastUpdatedAt: NSDate?, callback: ConversationsResultBlock) {
        if let query = Conversation.query(), currentUser = User.currentUser() {
            QueryUtils.bindQueryParamsForInfiniteLoading(query, lastUpdatedAt: lastUpdatedAt)
            query.includeKey("post")
            query.includeKey("users")
            query.whereKey("post", equalTo: post)
            query.whereKey("users", equalTo: currentUser)
            query.whereKey("usersChooseHideConversation", notEqualTo: currentUser)
            query.findObjectsInBackgroundWithBlock({ (pfObjs, error) -> Void in
                guard error == nil else {
                    callback(conversations: nil, error: error)
                    return
                }
                if let conversations = pfObjs as? [Conversation] {
                    callback(conversations: conversations, error: nil)
                }
            })
        }
    }
}