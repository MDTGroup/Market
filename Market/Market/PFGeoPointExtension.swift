//
//  PFGeoPointExtension.swift
//  Market
//
//  Created by Ngo Thanh Tai on 1/4/16.
//  Copyright © 2016 MDT Group. All rights reserved.
//

import Parse

extension PFGeoPoint {
    func getArea(callback: (location: String?, error: NSError?) -> Void) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) -> Void in
            guard error == nil else {
                callback(location: nil, error: error)
                return
            }
            if let placeMarks = placeMarks where placeMarks.count > 0 {
                let placeMark = placeMarks[0]
                if let addressDic = placeMark.addressDictionary {
                    
                    if let addressLines = addressDic["FormattedAddressLines"] as? [String] {
                        callback(location: addressLines.joinWithSeparator(", "), error: nil)
                    }
                }
            }
        })
    }
}