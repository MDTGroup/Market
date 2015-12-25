//
//  ViewController.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/3/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    static func gotoMain() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardID.main)
        UIApplication.sharedApplication().delegate!.window!!.rootViewController = vc
    }
}