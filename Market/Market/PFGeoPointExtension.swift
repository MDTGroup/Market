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
                    
                    var address = [String]()
                    if let district = addressDic["SubAdministrativeArea"] as? String {
                        address.append(district)
                    }
                    if let city = addressDic["City"] as? String {
                        address.append(city)
                    } else if let state = addressDic["State"] as? String {
                        address.append(state)
                    }
                    
                    if let country = addressDic["Country"] as? String {
                        address.append(country)
                    }
                    
                    let finalAddress = address.joinWithSeparator(", ")
                    if !finalAddress.isEmpty {
                        callback(location: finalAddress, error: nil)
                    }
                }
            }
        })
    }
}