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
        return "Conversations"
    }
    
    @NSManaged var users: [User]
    @NSManaged var usersChooseHideConversation: [User]
    @NSManaged var post: Post
    @NSManaged var messages: PFRelation
    
    func getConversations(lastUpdatedAt: NSDate?, callback: ConversationResultBlock) {
        if let query = Conversation.query(), currentUser = User.currentUser() {
            QueryUtils.bindQueryParamsForInfiniteLoading(query, lastUpdatedAt: lastUpdatedAt)
            query.whereKey("users", containedIn: [currentUser])
            query.whereKey("usersChooseHideConversation", notContainedIn: [currentUser])
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
    
    func getMessages(lastUpdatedAt: NSDate?, callback: MessageResultBlock) {
        let query = messages.query()
        query.whereKey("conversation", equalTo: self)
        QueryUtils.bindQueryParamsForInfiniteLoading(query, lastUpdatedAt: lastUpdatedAt)
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
    
    func addMessage(currentUser: User, text: String) {
        let message = Message()
        message.user = currentUser
        message.text = text
        message.conversation = self
        messages.addObject(message)
    }
    
    func hideConversation() {
        if let currentUser = User.currentUser() {
            if !usersChooseHideConversation.contains(currentUser) {
                usersChooseHideConversation.append(currentUser)
                saveInBackground()
            }
        }
    }
    
    func showConversation() {
        if let currentUser = User.currentUser() {
            if usersChooseHideConversation.contains(currentUser) {
                if let index = usersChooseHideConversation.indexOf(currentUser) {
                    usersChooseHideConversation.removeAtIndex(index)
                    saveInBackground()
                }
            }
        }
    }
    
    static func addConversation(toUser: User, post: Post, text: String) {
        if let currentUser = User.currentUser() {
            if currentUser.objectId == toUser.objectId {
                return
            }
            if let query = Conversation.query() {
                let users = [currentUser, toUser]
                query.whereKey("post", equalTo: post)
                query.whereKey("users", containsAllObjectsInArray: users)
                do {
                    if let conversations = try query.findObjects() as? [Conversation]
                    {
                        if conversations.count == 0 {
                            let conversation = Conversation()
                            conversation.users = users
                            conversation.usersChooseHideConversation = []
                            conversation.post = post
                            conversation.addMessage(currentUser, text: text)
                        } else if conversations.count == 1 {
                            let conversation = conversations[0]
                            conversation.usersChooseHideConversation = []
                            conversation.addMessage(currentUser, text: text)
                        } else {
                            print("Why? Conversations should only have one with these post")
                        }
                    }
                } catch {
                    
                }
            }
        }
    }
}