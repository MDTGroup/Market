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
    
    private var newsFeedTab: UITabBarItem!
    private var messageTab: UITabBarItem!
    private var notificationTab: UITabBarItem!
    private var numUnreadNotification = 0
    private var numUnreadMessage = 0
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
        messageTab.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
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
                self.notificationTab.badgeValue = "\(numUnread)"
            } else {
                self.notificationTab.badgeValue = nil
            }
            self.updateAppBadge()
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
                self.messageTab.badgeValue = "\(numUnread)"
            } else {
                self.messageTab.badgeValue = nil
            }
            self.updateAppBadge()
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