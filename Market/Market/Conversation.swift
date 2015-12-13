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
}