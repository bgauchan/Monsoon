//
//  Notification.swift
//  Monsoon
//
//  Created by Bardan Gauchan on 2015-05-16.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

import Foundation
import Parse

class Helper {
    
    func getDateStringAndTimeLeft(tvShow: PFObject)  -> (dateString: String, timeLeft: Int) {
        
        var dateString = ""
        var timeLeft = 0
        let currentDate = NSDate()
        
        let currentSeason = tvShow["currentSeason"] as! Int
        let seasonStartDate = tvShow["seasonStartDate"] as! NSDate
        let seasonEndDate = tvShow["seasonEndDate"] as! NSDate
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        
        var dateComparisionResult:NSComparisonResult = currentDate.compare(seasonStartDate as NSDate)
        
        if dateComparisionResult == NSComparisonResult.OrderedAscending
        {
            // Season hasn't started yet
            dateString = "Season \(currentSeason) starts in \(dateFormatter.stringFromDate(seasonStartDate))"
            timeLeft = dateDifferenceInString(seasonStartDate)
        }
        else if dateComparisionResult == NSComparisonResult.OrderedDescending
        {
            // the season has already started, now we check the end date
            dateComparisionResult = currentDate.compare(seasonEndDate)
            
            if dateComparisionResult == NSComparisonResult.OrderedDescending{
                dateString = "Season \(currentSeason) ended on \(dateFormatter.stringFromDate(seasonEndDate))"
            } else {
                dateString = "Season \(currentSeason) ends in \(dateFormatter.stringFromDate(seasonEndDate))"
            }
            
            timeLeft = dateDifferenceInString(seasonEndDate)
        }
        else if dateComparisionResult == NSComparisonResult.OrderedSame
        {
            dateString = "Season \(currentSeason) starts today"
        }
        
        return (dateString, timeLeft)
    }
    
    private func dateDifferenceInString(date: NSDate) -> Int {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeZone = NSTimeZone()
        
        var currentDate = NSDate()
        let currentDateString = dateFormatter.stringFromDate(currentDate)
        currentDate = dateFormatter.dateFromString(currentDateString)!
        
        return date.daysFrom(currentDate)
    }
    
    func checkIfNotificationExists() {
        
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications {
            
            if let info = notification.userInfo as [NSObject: AnyObject]? {
                //var storedSeriesID = info["seriesID"] as! String
                
                println("\(notification.alertBody) => \(notification.fireDate)")
            }
        }
    }

    func scheduleNotification(tvShow: PFObject) {
        
        //let notificationDate = NSDate().dateByAddingTimeInterval(86400)
        var notificationDate: NSDate?
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        
        let showID = tvShow["seriesID"] as! Int
        let showName = tvShow["name"] as! String
        let currentSeason = tvShow["currentSeason"] as! Int
        let currentDate = NSDate()
        let seasonStartDate = tvShow["seasonStartDate"] as! NSDate
        let seasonEndDate = tvShow["seasonEndDate"] as! NSDate
        
        
        var alertText = ""
        
        var dateComparisionResult:NSComparisonResult = currentDate.compare(seasonStartDate as NSDate)
        
        if dateComparisionResult == NSComparisonResult.OrderedAscending {
            
            // Season hasn't started yet
            alertText += "Season \(currentSeason) of \(showName) starts tomorrow!"
            
            // setting the notification date to be a day early = -86400 seconds
            notificationDate = seasonStartDate.dateByAddingTimeInterval(-86400)
            
        } else if dateComparisionResult == NSComparisonResult.OrderedDescending {
            
            // the season has already started, now we check the end date
            dateComparisionResult = currentDate.compare(seasonEndDate)
            
            // if the end date is later than today
            if dateComparisionResult == NSComparisonResult.OrderedAscending {
                alertText += "Season \(currentSeason) of \(showName) ends tomorrow!"
                notificationDate = seasonEndDate.dateByAddingTimeInterval(-86400)
            } else {
                println("Tv Show already ended so no notification was added")
            }
        }
        
        //notificationDate = NSDate().dateByAddingTimeInterval(10)
        
        // don't schedule notifications if there is no notification date set (i.e. tv shows has ended)
        if notificationDate != nil {
            var notification = UILocalNotification()
            notification.alertBody = alertText
            notification.alertAction = "open"
            notification.fireDate = notificationDate
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = ["tvShowID": showID]
            notification.category = "watchlist"
            
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            println("notification added!")
        }
    }
    
    func removeNotification(tvShowID: Int) {
        for scheduledNotification in UIApplication.sharedApplication().scheduledLocalNotifications {
            
            var notification = scheduledNotification as! UILocalNotification
            
            if let info = notification.userInfo as [NSObject: AnyObject]? {
                var storedSeriesID = info["tvShowID"] as! Int
                
                if tvShowID == storedSeriesID {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                }
            }
        }
    }
}

extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear, fromDate: date, toDate: self, options: nil).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMonth, fromDate: date, toDate: self, options: nil).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitWeekOfYear, fromDate: date, toDate: self, options: nil).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay, fromDate: date, toDate: self, options: nil).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitHour, fromDate: date, toDate: self, options: nil).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMinute, fromDate: date, toDate: self, options: nil).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitSecond, fromDate: date, toDate: self, options: nil).second
    }
}