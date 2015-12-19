//
//  QueryUtils.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/13/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
import Parse

class QueryUtils {
    static func bindQueryParamsForInfiniteLoading(query:PFQuery, lastUpdatedAt:NSDate?, maxResult: Int = 20) -> PFQuery {
        query.limit = maxResult
        if let lastUpdatedAt = lastUpdatedAt {
            query.whereKey("createdAt", lessThan: lastUpdatedAt)
        }
        query.orderByDescending("createdAt")
        return query
    }
    
    static func bindQueryParamsForInfiniteLoadingForChat(query:PFQuery, lastCreatedAt:NSDate?, maxResult: Int = 20) -> PFQuery {
        query.limit = maxResult
        if let lastCreatedAt = lastCreatedAt {
            query.whereKey("createdAt", greaterThan: lastCreatedAt)
        }
        query.orderByAscending("createdAt")
        return query
    }
}