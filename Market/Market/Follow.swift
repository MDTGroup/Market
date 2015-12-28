//
//  Follow.swift
//  ParseStarterProject-Swift
//
//  Created by Ngo Thanh Tai on 12/11/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import Parse

class Follow: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "Follows"
    }
    
    @NSManaged var from: User
    @NSManaged var to: User
}

// MARK: Add follow
extension Follow {
    static func follow(targetUser: User, callback: PFBooleanResultBlock) {
        guard User.currentUser() != nil else {
            print("Current user is nil")
            return
        }
        
        if let query = Follow.query(), currentUser = User.currentUser() {
            query.whereKey("from", equalTo: currentUser)
            query.whereKey("to", equalTo: targetUser)
            query.countObjectsInBackgroundWithBlock({ (num, error) -> Void in
                guard error == nil else {
                    print(error)
                    return
                }
                
                if num > 0 {
                    print("Error! Already follow. Cannot follow again. Need to fix UI bug.")
                    return
                } else {
                    let follow = Follow()
                    follow.from = currentUser
                    follow.to = targetUser
                    follow.saveInBackgroundWithBlock(callback)
                    
                    currentUser.numFollowing = nil
                }
            })
        }
    }
    
    static func unfollow(targetUser: User, callback: PFBooleanResultBlock) {
        guard User.currentUser() != nil else {
            print("Current user is nil")
            return
        }
        if let query = Follow.query(), currentUser = User.currentUser() {
            query.whereKey("from", equalTo: currentUser)
            query.whereKey("to", equalTo: targetUser)
            query.findObjectsInBackgroundWithBlock({ (followings, error) -> Void in
                guard error == nil else {
                    callback(false, error)
                    return
                }
                PFObject.deleteAllInBackground(followings, block: callback)
            })
            currentUser.numFollowing = nil
        }
    }
}