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
    
    func getPosts(lastUpdated: NSDate?, callback: (posts: [Post]?, error: NSError?) -> Void) {
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
}
