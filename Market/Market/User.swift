//
//  User.swift
//  ParseStarterProject-Swift
//
//  Created by Ngo Thanh Tai on 12/11/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import Parse

class User: PFUser {
    @NSManaged var avatar: PFFile?
    @NSManaged var fullName: String
    @NSManaged var gender: Int
    @NSManaged var address: String?
    @NSManaged var phone: String?
    @NSManaged var role: PFRole
    @NSManaged var config: PFConfig
    @NSManaged var savedPosts: PFRelation
    @NSManaged var votedPosts: PFRelation
    @NSManaged var keywords: [String]
    
    func getPosts(lastUpdated:NSDate?, callback: PostResultBlock) {
        if let query = Post.query() {
            query.limit = 20
            if let lastUpdated = lastUpdated {
                query.whereKey("updatedAt", lessThan: lastUpdated)
            }
            query.includeKey("user")
            query.whereKey("isDeleted", equalTo: false)
            query.whereKey("sold", equalTo: false)
            query.whereKey("isDeleted", equalTo: false)
            query.whereKey("user", equalTo: self)
            query.orderByDescending("updatedAt")
            
            query.findObjectsInBackgroundWithBlock({ (pfObj: [PFObject]?, error: NSError?) -> Void in
                guard error == nil else {
                    callback(posts: nil, error: error)
                    return
                }
                if let posts = pfObj as? [Post] {
                    callback(posts: posts, error: nil)
                }
            })
        }
    }
    
    // This user is following who
    func getFollowings(callback: UserResultBlock) {
        if let query = Follow.query() {
            query.selectKeys(["to"])
            query.includeKey("to")
            query.whereKey("from", equalTo: self)
            query.findObjectsInBackgroundWithBlock({ (pfObjs, error) -> Void in
                guard error == nil else {
                    callback(users: nil, error: error)
                    return
                }
                
                if let followings = pfObjs as? [Follow] {
                    var users = [User]()
                    for following in followings {
                        users.append(following.to)
                    }
                    callback(users: users, error: nil)
                }
            })
        }
    }
    
    // Who is following this user
    func getFollowers(callback: UserResultBlock) {
        if let query = Follow.query() {
            query.selectKeys(["from"])
            query.includeKey("from")
            query.whereKey("to", equalTo: self)
            query.findObjectsInBackgroundWithBlock({ (pfObjs, error) -> Void in
                guard error == nil else {
                    callback(users: nil, error: error)
                    return
                }
                
                if let followers = pfObjs as? [Follow] {
                    var users = [User]()
                    for follower in followers {
                        users.append(follower.from)
                    }
                    callback(users: users, error: nil)
                }
            })
        }
    }
    
    func didIFollowTheUser(callback: PFBooleanResultBlock) {
        let currentUser = User.currentUser()
        self.getFollowers({ (followers, error) -> Void in
            if followers != nil {
                for follower in followers! {
                    if follower.objectId == currentUser?.objectId {
                        callback(true, nil)
                        return
                    }
                }
                callback(false, nil)
            } else {
                print(error)
                callback(false, error)
            }
        })
    }
    
    func getSavedPosts(lastUpdatedAt:NSDate?, callback: PostResultBlock) {
        let query = savedPosts.query()
        query.includeKey("user")
        QueryUtils.bindQueryParamsForInfiniteLoading(query, lastUpdatedAt: lastUpdatedAt)
        query.findObjectsInBackgroundWithBlock { (pfObjs, error) -> Void in
            guard error == nil else {
                callback(posts: nil, error: error)
                return
            }
            
            if let posts = pfObjs as? [Post] {
                callback(posts: posts, error: nil)
            }
        }
    }
    
    func getVotedPosts(callback: PostResultBlock) {
        votedPosts.query().findObjectsInBackgroundWithBlock { (pfObjs, error) -> Void in
            guard error == nil else {
                callback(posts: nil, error: error)
                return
            }
            
            if let posts = pfObjs as? [Post] {
                callback(posts: posts, error: nil)
            }
        }
    }
    
    func addKeyword(keyword: String, callback: PFBooleanResultBlock) {
        if keywords.contains(keyword) {
            callback(false, NSError(domain: "The keyword \(keyword) existed.", code: 0, userInfo: nil))
            return
        }
        keywords.append(keyword)
        saveInBackgroundWithBlock(callback)
    }
    
    func removeKeyword(keyword: String, callback: PFBooleanResultBlock) {
        if keywords.contains(keyword) {
            if let index = keywords.indexOf(keyword) {
                keywords.removeAtIndex(index)
            }
        }
        saveInBackgroundWithBlock(callback)
    }
    
    //MARK: Notifications
    func getNotifications(lastUpdatedAt: NSDate?, callback: NotificationResultBlock) {
        if let query = Notification.query() {
            QueryUtils.bindQueryParamsForInfiniteLoading(query, lastUpdatedAt: lastUpdatedAt)
            print(self.fullName)
            query.whereKey("toUsers", equalTo: self)
            query.includeKey("post")
            query.findObjectsInBackgroundWithBlock({ (pfObjs, error) -> Void in
                guard error == nil else {
                    callback(notifications: nil, error: error)
                    return
                }
                if let notifications = pfObjs as? [Notification] {
                    callback(notifications: notifications, error: nil)
                }
            })
        }
    }
}
