//
//  User.swift
//  ParseStarterProject-Swift
//
//  Created by Ngo Thanh Tai on 12/11/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import Parse

enum NotificationSetting: Int {
    case SavedPosts = 1
    case Following = 2
    case Keywords = 3
}

class User: PFUser {
    @NSManaged var avatar: PFFile?
    @NSManaged var fullName: String
    @NSManaged var gender: Int
    @NSManaged var address: String?
    @NSManaged var phone: String?
    @NSManaged var role: PFRole
    @NSManaged var config: PFConfig
    @NSManaged var keywords: [String]
    @NSManaged var savedPosts: PFRelation
    @NSManaged var votedPosts: PFRelation
    
    // Reset to nil to make it get data from server
    var numFollowing: Int32?
    var numFollower: Int32?
    
    var enableNotificationForSavedPosts: Bool = false
    var enableNotificationForFollowing: Bool = false
    var enableNotificationForKeywords: Bool = false
    
    func getPosts(lastCreatedAt:NSDate?, callback: PostResultBlock) {
        if let query = Post.query() {
            query.selectKeys(["title", "descriptionText", "price", "user", "medias", "location", "locationName", "condition", "sold", "voteCounter"])
            query.includeKey("user")
            query.whereKey("isDeleted", equalTo: false)
            query.whereKey("user", equalTo: self)
            QueryUtils.bindQueryParamsForInfiniteLoading(query, lastCreatedAt: lastCreatedAt)
            query.cachePolicy = .NetworkElseCache
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
    
    func getNumFollowings(callback: PFIntegerResultBlock) {
        if let numFollowing = numFollowing {
            callback(numFollowing, nil)
            return
        }
        if let query = Follow.query() {
            query.selectKeys(["to"])
            query.includeKey("to")
            query.whereKey("from", equalTo: self)
            query.cachePolicy = .CacheThenNetwork
            query.countObjectsInBackgroundWithBlock({ (num, error) -> Void in
                self.numFollowing = num
                callback(num, error)
            })
        }
    }
    
    func getNumFollowers(callback: PFIntegerResultBlock) {
        if let numFollower = numFollower {
            callback(numFollower, nil)
            return
        }
        if let query = Follow.query() {
            query.selectKeys(["from"])
            query.includeKey("from")
            query.whereKey("to", equalTo: self)
            query.cachePolicy = .CacheThenNetwork
            query.countObjectsInBackgroundWithBlock({ (num, error) -> Void in
                self.numFollower = num
                callback(num, error)
            })
        }
    }
    
    // This user is following who
    func getFollowings(callback: UserResultBlock) {
        if let query = Follow.query() {
            query.selectKeys(["to"])
            query.includeKey("to")
            query.whereKey("from", equalTo: self)
            query.cachePolicy = .NetworkElseCache
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
            query.cachePolicy = .NetworkElseCache
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
        if let query = Follow.query(), currentUser = User.currentUser() {
            query.selectKeys([])
            query.whereKey("from", equalTo: currentUser)
            query.whereKey("to", equalTo: self)
            query.cachePolicy = .NetworkElseCache
            
            query.countObjectsInBackgroundWithBlock({ (num, error) -> Void in
                guard error == nil else {
                    print(error)
                    callback(false, error)
                    return
                }
                callback(num > 0, nil)
            })
        }
    }
    
    func getSavedPosts(lastUpdatedAt:NSDate?, callback: PostResultBlock) {
        let query = savedPosts.query()
        query.includeKey("user")
        QueryUtils.bindQueryParamsForInfiniteLoading(query, lastUpdatedAt: lastUpdatedAt)
        query.cachePolicy = .NetworkElseCache
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
        let query = votedPosts.query()
        query.cachePolicy = .NetworkElseCache
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
    
    func addKeyword(keyword: String, callback: PFBooleanResultBlock) {
        if keywords.contains(keyword) {
            callback(false, NSError(domain: "The keyword \(keyword) existed.", code: 0, userInfo: nil))
            return
        }
        keywords.append(keyword)
        saveInBackgroundWithBlock(callback)
        fetchInBackground()
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
    func getNotifications(lastCreatedAt: NSDate?, callback: NotificationResultBlock) {
        if let query = Notification.query() {
            let cachePolicy = PFCachePolicy.NetworkElseCache
            query.selectKeys(["post", "fromUser", "type", "extraInfo"])
            QueryUtils.bindQueryParamsForInfiniteLoading(query, lastCreatedAt: lastCreatedAt, maxResult: 12)
            query.includeKey("post")
            query.includeKey("fromUser")
            query.whereKey("toUsers", equalTo: self)
            
            if let postQuery = Post.query() {
                postQuery.whereKey("isDeleted", equalTo: false)
                query.whereKey("post", matchesQuery: postQuery)
            }
            
            query.cachePolicy = cachePolicy
            query.findObjectsInBackgroundWithBlock({ (pfObjs, error) -> Void in
                guard error == nil else {
                    callback(notifications: nil, error: error)
                    return
                }
                if let notifications = pfObjs as? [Notification] {
                    
                    if let queryForUnread = Notification.query() {
                        QueryUtils.bindQueryParamsForInfiniteLoading(queryForUnread, lastCreatedAt: lastCreatedAt)
                        queryForUnread.selectKeys([])
                        queryForUnread.whereKey("toUsers", equalTo: self)
                        queryForUnread.whereKey("readUsers", equalTo: self)
                        
                        if let postQuery = Post.query() {
                            postQuery.whereKey("isDeleted", equalTo: false)
                            queryForUnread.whereKey("post", matchesQuery: postQuery)
                        }
                        
                        queryForUnread.cachePolicy = cachePolicy
                        queryForUnread.findObjectsInBackgroundWithBlock({ (notificationsUnread, error) -> Void in
                            guard error == nil else {
                                callback(notifications: nil, error: error)
                                return
                            }
                            if let notificationsUnread = notificationsUnread as? [Notification] {
                                for notification in notifications {
                                    for notificationUnread in notificationsUnread {
                                        if notification.objectId == notificationUnread.objectId {
                                            notification.isRead = true
                                        }
                                    }
                                }
                                callback(notifications: notifications, error: nil)
                            }
                        })
                    }
                    
                }
            })
        }
    }
    
    func getNotificationsForRefreshingData(lastCreatedAt: NSDate?, callback: NotificationResultBlock) {
        if let query = Notification.query() {
            query.selectKeys(["post", "fromUser", "type", "extraInfo"])
            query.includeKey("post")
            query.includeKey("fromUser")
            query.whereKey("toUsers", equalTo: self)
            
            if let postQuery = Post.query() {
                postQuery.whereKey("isDeleted", equalTo: false)
                query.whereKey("post", matchesQuery: postQuery)
            }
            
            if let lastCreatedAt = lastCreatedAt {
                query.whereKey("createdAt", greaterThan: lastCreatedAt)
            }
            query.orderByDescending("createdAt")
            query.cachePolicy = .NetworkOnly
            query.findObjectsInBackgroundWithBlock({ (pfObjs, error) -> Void in
                guard error == nil else {
                    callback(notifications: nil, error: error)
                    return
                }
                if let notifications = pfObjs as? [Notification] {
                    if let queryForUnread = Notification.query() {
                        QueryUtils.bindQueryParamsForInfiniteLoading(queryForUnread, lastCreatedAt: lastCreatedAt)
                        queryForUnread.selectKeys([])
                        queryForUnread.whereKey("toUsers", equalTo: self)
                        queryForUnread.whereKey("readUsers", equalTo: self)
                        
                        if let postQuery = Post.query() {
                            postQuery.whereKey("isDeleted", equalTo: false)
                            queryForUnread.whereKey("post", matchesQuery: postQuery)
                        }
                        
                        queryForUnread.cachePolicy = .NetworkOnly
                        queryForUnread.findObjectsInBackgroundWithBlock({ (notificationsUnread, error) -> Void in
                            guard error == nil else {
                                callback(notifications: nil, error: error)
                                return
                            }
                            if let notificationsUnread = notificationsUnread as? [Notification] {
                                for notification in notifications {
                                    for notificationUnread in notificationsUnread {
                                        if notification.objectId == notificationUnread.objectId {
                                            notification.isRead = true
                                        }
                                    }
                                }
                                callback(notifications: notifications, error: nil)
                            }
                        })
                    }
                    
                }
            })
        }
    }
    
    func updateNotificationSettings() {
        var needToSaveToCloud = false
        let installation = PFInstallation.currentInstallation()
        var enableNotificationForSavedPosts = installation.valueForKey("enableNotificationForSavedPosts") as? Bool
        if enableNotificationForSavedPosts == nil {
            enableNotificationForSavedPosts = true
            needToSaveToCloud = true
        }
        self.enableNotificationForSavedPosts = enableNotificationForSavedPosts!
        
        var enableNotificationForFollowing = installation.valueForKey("enableNotificationForFollowing") as? Bool
        if enableNotificationForFollowing == nil {
            enableNotificationForFollowing = true
            needToSaveToCloud = true
        }
        self.enableNotificationForFollowing = enableNotificationForFollowing!
        
        var enableNotificationForKeywords = installation.valueForKey("enableNotificationForKeywords") as? Bool
        if enableNotificationForKeywords == nil {
            enableNotificationForKeywords = true
            needToSaveToCloud = true
        }
        self.enableNotificationForKeywords = enableNotificationForKeywords!
        
        if needToSaveToCloud {
            let installation = PFInstallation.currentInstallation()
            installation.setValue(enableNotificationForSavedPosts, forKey: "enableNotificationForSavedPosts")
            installation.setValue(enableNotificationForFollowing, forKey: "enableNotificationForFollowing")
            installation.setValue(enableNotificationForKeywords, forKey: "enableNotificationForKeywords")
            installation.saveInBackground()
        }
    }
    
    func updateNotificationConfigForType(notificationSetting: NotificationSetting, enable: Bool) {
        let installation = PFInstallation.currentInstallation()
        switch notificationSetting {
        case .SavedPosts:
            self.enableNotificationForSavedPosts = enable
            installation.setValue(enable, forKey: "enableNotificationForSavedPosts")
        case .Keywords:
            self.enableNotificationForKeywords = enable
            installation.setValue(enable, forKey: "enableNotificationForKeywords")
        case .Following:
            self.enableNotificationForFollowing = enable
            installation.setValue(enable, forKey: "enableNotificationForFollowing")
        }
        installation.saveInBackground()
    }
}