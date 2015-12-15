//
//  AppDelegate.swift
//  Market
//
//  Created by Ngo Thanh Tai on 12/3/15.
//  Copyright © 2015 MDT Group. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Home", bundle: nil)


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupForParse(application, launchOptions: launchOptions)
        
        let newUser = User.currentUser()
        
        if newUser != nil {
            let vc = storyboard.instantiateViewControllerWithIdentifier("homeVC") //as! UIViewController
            window?.rootViewController = vc
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

//MARK: Set up PARSE
extension AppDelegate {
    func setupForParse(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
        setupKey()
        setupSubclass()
        setupACL()
//        setupPushNotifications(application, launchOptions: launchOptions)
        
        
    }
    
    func setupACL() {
        let defaultACL = PFACL();
        defaultACL.publicReadAccess = true
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
    }
    
    func setupKey() {
        guard let config = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Config", ofType: "plist")!) else {
            print("Please set up Parse keys in Config.plist file", terminator: "\n")
            return
        }
        
        let applicationId = config["parse_application_id"] as? String
        let clientKey = config["parse_client_key"] as? String
        Parse.setApplicationId(applicationId!, clientKey: clientKey!)
    }
    
    func setupSubclass() {
        Vote.registerSubclass()
        User.registerSubclass()
        Post.registerSubclass()
        Follow.registerSubclass()
    }
    
//    func setupPushNotifications(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
//        if application.applicationState != UIApplicationState.Background {
//            // Track an app open here if we launch with a push, unless
//            // "content_available" was used to trigger a background push (introduced in iOS 7).
//            // In that case, we skip tracking here to avoid double counting the app-open.
//            
//            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
//            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
//            var noPushPayload = false;
//            if let options = launchOptions {
//                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
//            }
//            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
//                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
//            }
//        }
//        
//        if #available(iOS 8.0, *) {
//            let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
//            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
//            application.registerUserNotificationSettings(settings)
//            application.registerForRemoteNotifications()
//        } else {
//            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
//            application.registerForRemoteNotificationTypes(types)
//        }
//    }
//    
//    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        let installation = PFInstallation.currentInstallation()
//        installation.setDeviceTokenFromData(deviceToken)
//        installation.saveInBackground()
//        installation.channels = ["global"]
//        
//        PFPush.subscribeToChannelInBackground("global") { (succeeded: Bool, error: NSError?) in
//            if succeeded {
//                print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.\n");
//            } else {
//                print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.\n", error)
//            }
//        }
//    }
//    
//    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
//        if error.code == 3010 {
//            print("Push notifications are not supported in the iOS Simulator.\n")
//        } else {
//            print("application:didFailToRegisterForRemoteNotificationsWithError: %@\n", error)
//        }
//    }
//    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        PFPush.handlePush(userInfo)
//        if application.applicationState == UIApplicationState.Inactive {
//            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
//        }
//    }
//    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//         if application.applicationState == UIApplicationState.Inactive {
//             PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
//        }
//    }
}