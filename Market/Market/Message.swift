//
//  Message.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/13/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
import Parse

class Message: PFObject, PFSubclassing {
    static func parseClassName() -> String {
        return "Message"
    }
    @NSManaged var conversation: Conversation
    @NSManaged var user: User
    @NSManaged var text: String
}