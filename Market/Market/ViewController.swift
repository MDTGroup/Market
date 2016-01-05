//
//  ViewController.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/3/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    static func gotoMain(animated: Bool) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        let vc = StoryboardInstance.main.instantiateViewControllerWithIdentifier(StoryboardID.main)
        let window = UIApplication.sharedApplication().delegate!.window!!
        if animated {
        if let rootVC = window.rootViewController {
            UIView.transitionFromView(rootVC.view, toView: vc.view, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: { (finished) -> Void in
                window.rootViewController = vc
            })
        }
        } else {
            window.rootViewController = vc
        }
    }
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var createAccountView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginView.layer.cornerRadius = 6
        loginView.layer.borderWidth = 1
        loginView.layer.borderColor = MyColors.themeColor.CGColor
        loginView.layer.masksToBounds = true
        
        createAccountView.layer.cornerRadius = 6
        createAccountView.layer.masksToBounds = true   
    }
}