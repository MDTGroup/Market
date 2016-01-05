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
    case Following = "notificationsForFollowers"
    case Keywords = "notificationsForKeywords"
}

class Notification: PFObject, PFSubclassing {
    @NSManaged var post: Post
    @NSManaged var fromUser: User
    @NSManaged var type: Int
    @NSManaged var extraInfo: String
    @NSManaged var toUsers: PFRelation
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
    
    static func markRead(id: String) {
        var params = [String : AnyObject]()
        params["id"] = id
        PFCloud.callFunctionInBackground("notification_markRead", withParameters: params) { (result, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
        }
    }
    
    static func sendNotificationForNewPost(post: Post) {
        var params = [String : AnyObject]()
        params["postId"] = post.objectId!
        params["title"] = post.title
        params["price"] =  post.price.formatVND()
        Notification.sendNotifications(NotificationType.Following, params: params, callback: { (success, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
        })
        
        params["description"] = post.descriptionText
        Notification.sendNotifications(NotificationType.Keywords, params: params) { (success, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
        }
    }
    
    static func sendNotificationForUpdatedPost(post: Post, changeDescription: String) {
        if changeDescription.isEmpty {
            return
        }
        var params = [String : AnyObject]()
        params["postId"] = post.objectId!
        params["title"] = post.title
        params["price"] =  post.price.formatVND()
        params["extraInfo"] = changeDescription
        Notification.sendNotifications(NotificationType.SavedPost, params: params, callback: { (success, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
        })
    }
}