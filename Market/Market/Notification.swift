//
//  Notification.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/14/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
import Parse

enum NotificationType: String {
    case SavedPost = "notifiationsForSavedPosts"
    case Followers = "notifiationsForFollowers"
    case Keywords = "notifiationsForKeywords"
}

class Notification: PFObject, PFSubclassing {
    @NSManaged var post: Post
    @NSManaged var toUsers: PFRelation
    @NSManaged var fromUser: User
    @NSManaged var type: Int
    
    static func parseClassName() -> String {
        return "Notification"
    }
    
    static func sendNotifications(type: NotificationType, params: [String : AnyObject], callback: PFBooleanResultBlock) {
        PFCloud.callFunctionInBackground(type.rawValue, withParameters: params) { (results, error) -> Void in
            guard error == nil else {
                callback(false, error)
                return
            }
            
            callback(true, nil)
        }
    }
}