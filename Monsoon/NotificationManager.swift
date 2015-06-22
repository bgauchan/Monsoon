//
//  NotificationManager.swift
//  Monsoon
//
//  Created by Bardan Gauchan on 2015-06-01.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

import UIKit
import Foundation
import Parse

class NotificationManager {
    
    class func checkIfNotificationExists() {
        
        let scheduledLocalNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
        
        for notification in scheduledLocalNotifications! {
            
            if let _ = notification.userInfo as [NSObject: AnyObject]? {
                print("\(notification.alertBody) => \(notification.fireDate)")
            }
        }
    }
    
    class func scheduleNotification(tvShow: PFObject) {
        
        var notificationDate: NSDate?
        var notificationText = ""
        
        let showID = tvShow["seriesID"] as! Int
        
        (notificationText, notificationDate) = Helper.getNotificationTextAndDates(tvShow)
        
        // don't schedule notifications if there is no notification date set (i.e. tv shows has ended)
        if notificationDate != nil {
            let notification = UILocalNotification()
            notification.alertBody = notificationText
            notification.alertAction = "open"
            notification.fireDate = notificationDate
            notification.timeZone = NSTimeZone(name: "GMT")
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = ["tvShowID": showID]
            notification.category = "watchlist"
            
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            print("notification added!")
        }
    }
    
    class func removeNotificationIfExists(tvShowID: Int) {
        for scheduledNotification in UIApplication.sharedApplication().scheduledLocalNotifications! {
            
            let notification = scheduledNotification as UILocalNotification
            
            if let info = notification.userInfo as [NSObject: AnyObject]? {
                let storedSeriesID = info["tvShowID"] as! Int
                
                if tvShowID == storedSeriesID {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                }
            }
        }
    }
}