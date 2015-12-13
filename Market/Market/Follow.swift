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
        
        let follow = Follow()
        follow.from = User.currentUser()!
        follow.to = targetUser
        follow.saveInBackgroundWithBlock(callback)
    }
}