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
    
    class func getDateStringAndTimeLeft(tvShow: PFObject)  -> (dateString: String, timeLeft: Int) {
        
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
    
    class func dateDifferenceInString(date: NSDate) -> Int {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeZone = NSTimeZone()
        
        var currentDate = NSDate()
        var currentDateString = dateFormatter.stringFromDate(currentDate)
        currentDate = dateFormatter.dateFromString(currentDateString)!
        
        return date.daysFrom(currentDate)
    }
    
    class func getNotificationTextAndDates(tvShow: PFObject) -> (notificationText: String, notificationDate: NSDate?) {
        
        var notificationDate: NSDate?
        var notificationText = ""
        
        let showName = tvShow["name"] as! String
        let currentSeason = tvShow["currentSeason"] as! Int
        let currentDate = NSDate()
        let seasonStartDate = tvShow["seasonStartDate"] as! NSDate
        let seasonEndDate = tvShow["seasonEndDate"] as! NSDate
        
        var dateComparisionResult:NSComparisonResult = currentDate.compare(seasonStartDate as NSDate)
        
        if dateComparisionResult == NSComparisonResult.OrderedAscending {
            
            // Season hasn't started yet
            notificationText += "Season \(currentSeason) of \(showName) starts tomorrow!"
            
            // setting the notification date to be a day early = -86400 seconds
            notificationDate = seasonStartDate.dateByAddingTimeInterval(-86400)
            
        } else if dateComparisionResult == NSComparisonResult.OrderedDescending {
            
            // the season has already started, now we check the end date
            dateComparisionResult = currentDate.compare(seasonEndDate)
            
            // if the end date is later than today
            if dateComparisionResult == NSComparisonResult.OrderedAscending {
                notificationText += "Season \(currentSeason) of \(showName) ends tomorrow!"
                notificationDate = seasonEndDate.dateByAddingTimeInterval(-86400)
            } else {
                println("Tv Show already ended so no notification was added")
            }
        }
        
        return (notificationText, notificationDate)
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

extension UIColor {
    class func darkMonsoonColor() -> UIColor {
        return UIColor(red: 2/255, green: 2/255, blue: 19/255, alpha: 1.0)
    }
}