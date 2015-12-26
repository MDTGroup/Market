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
    @NSManaged var video: PFFile?
    @NSManaged var photo: PFFile?
    @NSManaged var location: PFGeoPoint?
    
    func sendPushNotification(targetUserId: String, postId: String, text: String, video: PFFile?, photo: PFFile?, location: PFGeoPoint?) {
        var params = [String : AnyObject]()
        params["targetUserId"] = targetUserId
        params["text"] = text
        params["isVideo"] = video != nil
        params["isPhoto"] = photo != nil
        params["isLocation"] = location != nil
        params["postId"] = postId
        PFCloud.callFunctionInBackground("messageNotification", withParameters: params)
    }
}