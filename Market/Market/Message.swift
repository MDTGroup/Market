//
//  Message.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/13/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
import Parse

class Message: PFObject, PFSubclassing {
    static func parseClassName() -> String {
        return "Message"
    }
    @NSManaged var conversation: Conversation
    @NSManaged var user: User
    @NSManaged var text: String
    
    func sendPushNotification(targetUserId: String, postId: String, text: String) {
        var params = [String : AnyObject]()
        params["targetUserId"] = targetUserId
        params["text"] = text
        params["postId"] = postId
        PFCloud.callFunctionInBackground("messageNotification", withParameters: params)
    }
}