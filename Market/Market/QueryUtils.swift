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
            query.whereKey("updatedAt", lessThan: lastUpdatedAt)
        }
        query.orderByDescending("updatedAt")
        return query
    }
}