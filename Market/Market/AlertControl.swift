//
//  AlertControl.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/27/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
import UIKit

class AlertControl {
    static func show(viewController: UIViewController, title: String, message: String, handler: ((alertAction: UIAlertAction) -> Void)?) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: handler)
        alertVC.addAction(alertAction)
        viewController.presentViewController(alertVC, animated: true, completion: nil)
    }
}