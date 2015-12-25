//
//  DoubleExtension.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/19/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
let billion: Double = 1000000000
let million: Double = 1000000
let thousand: Double = 1000
extension Double {    
    func formatCurrency() -> String {
        var formattedMoney = ""
        var remain = self
        if remain >= billion {
            let after = floor(remain/billion)
            remain = remain - after * billion
            formattedMoney += "\(Int(after))t"
        }
        if remain >= million {
            let after = floor(remain/million)
            remain = remain - after * million
            formattedMoney += "\(Int(after))tr"
        }
        if remain >= thousand {
            let after = floor(remain/thousand)
            remain = remain - after * thousand
            formattedMoney += "\(Int(after))k"
        }
        if formattedMoney.isEmpty {
            formattedMoney = "\(Int(self))"
        }
        return formattedMoney
    }
    
    func formatVND() -> String {
        // 1 234 457 890
        var remain = Int(self)
        var formattedMoney = "\(remain % 1000)"
        remain /= 1000
        while remain > 0 {
            formattedMoney = "\(remain % 1000)." + formattedMoney
            remain /= 1000
        }
        return formattedMoney + " VND"
    }
}