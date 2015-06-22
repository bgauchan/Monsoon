//
//  AppDelegate.swift
//  Monsoon
//
//  Created by Bardan Gauchan on 2015-05-04.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UINavigationBar.appearance().barTintColor = UIColor.orangeColor()
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        // change navigation item title color
        if let font = UIFont(name: "NexaBold", size: 20) {
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName: font]
        }
        
        // Parse Setup
        Parse.enableLocalDatastore()
        
        // Enable data sharing in main app.
        Parse.enableDataSharingWithApplicationGroupIdentifier("group.com.bardan.monsoon")
        
        // Initialize Parse.        
        Parse.setApplicationId("IP1rs5my0SYAbjLLUksy2D83vTWQGnNh2xp1Frsb", clientKey: "eeEM2IgofWFTRmYe4F62UoOLNQq8Tf63IUU7gsq9")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
        // register for Local Notifications
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        
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

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        // only present the alert if the app is not in background
        if application.applicationState != UIApplicationState.Background {
            
            let alert = UIAlertController(title: "Notification", message: notification.alertBody, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            let navigationController = application.windows[0].rootViewController as! UINavigationController
            let activeViewCont = navigationController.visibleViewController
            
            activeViewCont!.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
}

