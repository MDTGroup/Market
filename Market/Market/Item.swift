//
//  Item.swift
//  Market
//
//  Created by Dave Vo on 12/8/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation

class Item {
  var seller: String = ""
  var avatarURL: String = ""
  var title: String = ""
  var description: String = ""
  var itemImageUrl: String = ""
  var isNew: Bool = true
  var priceString: String = "0"
  var postedAt: NSDate!
  var timeSincePosted: String = ""
  
  init(dict: [String: AnyObject]) {
    
    seller = dict["seller"] as! String
    avatarURL = dict["avatarURL"] as! String
    title = dict["title"] as! String
    description = dict["description"] as! String
    itemImageUrl = dict["itemImageURL"] as! String
    isNew = dict["isNew"] as! Bool
    priceString = dict["price"] as! String
    postedAt = dict["postedAt"] as! NSDate
    
    let elapsedTime = NSDate().timeIntervalSinceDate(postedAt!)
    if elapsedTime < 60 {
      timeSincePosted = String(Int(elapsedTime)) + "s"
    } else if elapsedTime < 3600 {
      timeSincePosted = String(Int(elapsedTime / 60)) + "m"
    } else if elapsedTime < 24*3600 {
      timeSincePosted = String(Int(elapsedTime / 60 / 60)) + "h"
    } else {
      timeSincePosted = String(Int(elapsedTime / 60 / 60 / 24)) + "d"
    }
    
  }
}
