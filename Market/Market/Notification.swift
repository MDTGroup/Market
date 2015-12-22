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
    case SavedPost = "notificationsForSavedPosts"
    case Followers = "notificationsForFollowers"
    case Keywords = "notificationsForKeywords"
    
    static func fromInt(type: Int) -> String {
        switch type {
        case 1:
            return NotificationType.SavedPost.rawValue
        case 2:
            return NotificationType.Followers.rawValue
        case 3:
            return NotificationType.Keywords.rawValue
        default:
            return "nothing"
        }
    }
}

class Notification: PFObject, PFSubclassing {
    @NSManaged var post: Post
    @NSManaged var toUsers: PFRelation
    @NSManaged var fromUser: User
    @NSManaged var type: Int
    @NSManaged var readUsers: PFRelation
    
    var isRead = false
    
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
    
    static func countUnread(callback: PFIntegerResultBlock) {
        if let query = Notification.query(), currentUser = User.currentUser() {
            query.whereKey("toUsers", equalTo: currentUser)
            query.whereKey("readUsers", notEqualTo: currentUser)
            query.countObjectsInBackgroundWithBlock(callback)
        }
    }
    
    func markRead() {
        if isRead == false {
            self.isRead = true
            var params = [String : AnyObject]()
            params["id"] = objectId!
            PFCloud.callFunctionInBackground("notification_markRead", withParameters: params) { (result, error) -> Void in
                guard error == nil else {
                    print(error)
                    return
                }
            }
        }
    }
}