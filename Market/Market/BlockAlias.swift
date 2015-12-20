//
//  BlockAlias.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/13/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation

typealias UserResultBlock = (users: [User]?, error: NSError?) -> Void
typealias PostResultBlock = (posts: [Post]?, error: NSError?) -> Void
typealias ConversationsResultBlock = (conversations: [Conversation]?, error: NSError?) -> Void
typealias MessageResultBlock = (messages: [Message]?, error: NSError?) -> Void
typealias NotificationResultBlock = (notifications: [Notification]?, error: NSError?) -> Void
typealias ConversationResultBlock = (conversation: Conversation?, error: NSError?) -> Void