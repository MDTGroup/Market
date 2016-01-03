//
//  NSDataExtension.swift
//  Market
//
//  Created by Ngo Thanh Tai on 1/3/16.
//  Copyright © 2016 MDT Group. All rights reserved.
//

import Foundation

extension NSData {
    func toMB() -> Double {
        return Double(self.length / 1048576)
    }
    
    func toKB() -> Double {
        return Double(self.length / 1024)
    }
}