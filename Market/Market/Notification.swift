//
//  Notification.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/14/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
import Parse

enum NotificationType: Int {
    case SavedPost = 1
    case Following = 2
    case Keywords = 3
}

class Notification: PFObject, PFSubclassing {
    @NSManaged var post: Post
    @NSManaged var toUsers: PFRelation
    @NSManaged var fromUser: User
    @NSManaged var type: Int
    
    static func parseClassName() -> String {
        return "Notification"
    }
}