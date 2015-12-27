//
//  Vote.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/12/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Parse

class Vote: PFObject, PFSubclassing {
    
    @NSManaged var voteCounter: Int
    @NSManaged var voteUsers: PFRelation
    
    static func parseClassName() -> String {
        return "Votes"
    }
}