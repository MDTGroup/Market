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
    @NSManaged var keywords: PFRelation
    
    func getPosts(lastUpdated:NSDate?, callback: PostResultBlock) {
        if let query = Post.query() {
            query.limit = 20
            if let lastUpdated = lastUpdated {
                query.whereKey("updatedAt", lessThan: lastUpdated)
            }
            query.whereKey("sold", equalTo: false)
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
    
    func getFollowings(callback: UserResultBlock) {
        if let query = Follow.query(), currentUser = User.currentUser() {
            query.selectKeys(["to"])
            query.whereKey("from", equalTo: currentUser)
            query.findObjectsInBackgroundWithBlock({ (pfObjs, error) -> Void in
                guard error == nil else {
                    callback(users: nil, error: error)
                    return
                }

                if let users = pfObjs as? [User] {
                    callback(users: users, error: nil)
                }
            })
        }
    }
    
    func getFollowers(callback: UserResultBlock) {
        if let query = Follow.query(), currentUser = User.currentUser() {
            query.selectKeys(["from"])
            query.whereKey("to", equalTo: currentUser)
            query.findObjectsInBackgroundWithBlock({ (pfObjs, error) -> Void in
                guard error == nil else {
                    callback(users: nil, error: error)
                    return
                }
                
                if let users = pfObjs as? [User] {
                    callback(users: users, error: nil)
                }
            })
        }
    }
    
    func getSavedPosts(callback: PostResultBlock) {
        savedPosts.query().findObjectsInBackgroundWithBlock { (pfObjs, error) -> Void in
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
    
    func getKeywords(callback: KeywordResultBlock) {
        keywords.query().findObjectsInBackgroundWithBlock { (pfObjs, error) -> Void in
            guard error == nil else {
                callback(keywords: nil, error: error)
                return
            }
            
            if let keywords = pfObjs as? [Keyword] {
                callback(keywords: keywords, error: nil)
            }
        }
    }
}
