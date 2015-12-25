//
//  PushNotification.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/23/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
import MBProgressHUD

class PushNotification {
    static func handlePayload(application: UIApplication, userInfo: [NSObject : AnyObject]) {
        if let postId = userInfo["postId"] as? String {
            if application.applicationState == .Inactive {
                let rootViewController = application.delegate?.window??.rootViewController
                let hud = MBProgressHUD.showHUDAddedTo(rootViewController?.view, animated: true)
                hud.labelText = "Loading post..."
                let post = Post(withoutDataWithObjectId: postId)
                post.fetchInBackgroundWithBlock({ (result, error) -> Void in
                    guard error == nil else {
                        print(error)
                        return
                    }
                    if let result = result as? Post {
                        let vc = DetailViewController.instantiateViewController
                        vc.post = result
                        hud.hide(true)
                        rootViewController?.presentViewController(vc, animated: true, completion: nil)
                    }
                })
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(TabBarController.newNotification, object: nil)
            }
        } else if let messageInfo = userInfo["message"] as? NSDictionary,
            postId = messageInfo["postId"] as? String,
            fromUserId = messageInfo["fromUserId"] as? String,
            toUserId = messageInfo["toUserId"] as? String {
            if application.applicationState == .Inactive {
                let post = Post(withoutDataWithObjectId: postId)
                post.fetchInBackgroundWithBlock({ (post, error) -> Void in
                    guard error == nil else {
                        print(error)
                        return
                    }
                    if let post = post as? Post {
                        let fromUser = User(withoutDataWithObjectId: fromUserId)
                        let toUser = User(withoutDataWithObjectId: toUserId)
                       
                        ParentChatViewController.show(post, fromUser: fromUser, toUser: toUser)
                    }
                })
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(TabBarController.newMessage, object: nil)
            }
        }
    }
}