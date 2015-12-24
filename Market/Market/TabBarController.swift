//
//  TabBarController.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/23/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import Foundation
import UIKit
import Parse

class TabBarController: NSObject {
    static let instance = TabBarController()
    
    var newsFeedTab: UITabBarItem!
    var messageTab: UITabBarItem!
    var notificationTab: UITabBarItem!
    var numUnreadNotification = 0
    var numUnreadMessage = 0
    static let newNotification = "newNotification"
    static let newMessage = "newMessage"
    
    func initTabBar(tabBarController: UITabBarController) {
        if let items = tabBarController.tabBar.items {
            if items.count > 3 {
                messageTab = items[1]
                notificationTab = items[3]
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onRefreshNotificationBadge:", name: TabBarController.newNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onRefreshMessageBadge:", name: TabBarController.newMessage, object: nil)
        
        messageTab.image = UIImage(named: "message")
        messageTab.title = "Messages"
        
        notificationTab.image = UIImage(named: "noti")
        notificationTab.title = "Notifications"
        
        onRefreshNotificationBadge(nil)
        onRefreshMessageBadge(nil)
    }
    
    func onRefreshNotificationBadge(notification: NSNotification?) {
        Notification.countUnread { (numUnread, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            self.numUnreadNotification = Int(numUnread)
            if numUnread > 0 {
                self.updateAppBadge()
                self.notificationTab.badgeValue = "\(numUnread)"
            } else {
                self.notificationTab.badgeValue = nil
            }
        }
    }
    
    func onRefreshMessageBadge (notification: NSNotification?) {
        Conversation.countUnread { (numUnread, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            self.numUnreadMessage = Int(numUnread)
            if numUnread > 0 {
                self.updateAppBadge()
                self.messageTab.badgeValue = "\(numUnread)"
                PostsListViewController.needToRefresh = true
            } else {
                self.messageTab.badgeValue = nil
            }
        }
    }
    
    func updateAppBadge() {
        let totalBadge = numUnreadNotification + numUnreadMessage
        UIApplication.sharedApplication().applicationIconBadgeNumber = totalBadge
        
        let installation = PFInstallation.currentInstallation()
        installation["badge"] = totalBadge
        installation.saveInBackground()
    }
}