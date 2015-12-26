//
//  StringExtension.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/25/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func bold(strToBold: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        if let range = self.rangeOfString(strToBold) {
            attributedString.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(12.0)], range: NSRange(location: self.startIndex.distanceTo(range.startIndex), length: strToBold.characters.count))
        }
        return attributedString
    }
    
    func isEmail() -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
}