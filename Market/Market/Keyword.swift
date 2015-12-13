//
//  Keyword.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/13/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
import Parse

class Keyword: PFObject, PFSubclassing {
    static func parseClassName() -> String {
        return "Keywords"
    }
    
    @NSManaged var user: PFRelation
    @NSManaged var keyword: String
}
