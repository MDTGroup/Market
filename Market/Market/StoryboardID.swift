//
//  StoryboardID.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/19/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
import UIKit

struct StoryboardID {
    static let home:String = "home"
    static let postDetail:String = "postDetail"
    static let userTimeline:String = "userTimeline"
    static let main:String = "main"
    static let chatViewController:String = "chatViewController"
    static let messageViewController:String = "messageViewController"
    static let fullImageViewController: String = "fullImageViewController"
}

class StoryboardInstance {
    static let main = UIStoryboard(name: "Main", bundle: nil)
    static let home = UIStoryboard(name: "Home", bundle: nil)
    static let messages = UIStoryboard(name: "Messages", bundle: nil)
}