//
//  ViewController.swift
//  Monsoon
//
//  Created by Bardan Gauchan on 2015-05-04.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class WatchlistVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var watchlistBtn: UIBarButtonItem!
    @IBOutlet weak var archivedBtn: UIBarButtonItem!
    
    @IBOutlet weak var watchlist: UITableView!
    
    var showList = [PFObject]()
    //var tvShowController = TvShowController()
    
    let defaults = NSUserDefaults(suiteName: "group.com.bardan.monsoon")
    var shouldFetchFromServer = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.watchlist.separatorColor = UIColor.clearColor()
        self.watchlist.backgroundColor = UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1.0)
        
        // Toolbar buttons
        
        watchlistBtn.setTitleTextAttributes([ NSForegroundColorAttributeName: UIColor.orangeColor(), NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        archivedBtn.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // check the last fetched date
        let defaults = NSUserDefaults.standardUserDefaults()
        var currentDate = NSDate()
        
        if let lastFetchedDate = defaults.objectForKey("lastFetchedDate") as? NSDate {
            
            println("Time since last fetched => \(currentDate.timeIntervalSinceDate(lastFetchedDate))")
            
            // only fetch from the server if it's been more than 30 minutes
            if currentDate.timeIntervalSinceDate(lastFetchedDate) > 1800 {
                self.shouldFetchFromServer = true
                currentDate = NSDate()
                defaults.setObject(currentDate, forKey: "lastFetchedDate")
                defaults.synchronize()
            }
        } else {
            println("Not set up yet...")
            
            // if last fetched date doesn't exist in NSUserDefaults, create one
            defaults.setObject(currentDate, forKey: "lastFetchedDate")
            defaults.synchronize()
        }
        
        fetchShowsFromLocalStore()
    }
    
    func fetchShowsFromLocalStore(includeEndedShows: Bool? = nil) {
        
        // bool? = nil lets us declare optional paramteres
        
        var query: PFQuery = PFQuery(className: "TvShow")
        
        if includeEndedShows == nil {
            query.whereKey("seasonEndDate", greaterThan: NSDate())
        } else {
            query.whereKey("seasonEndDate", lessThanOrEqualTo: NSDate())
        }
        
        query.orderByAscending("seasonEndDate")
        query.fromLocalDatastore()
        
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if error != nil {
                print(error)
            } else {
                self.showList = objects as! [PFObject]
                self.sortShowsByTimeLeft()
                self.watchlist.reloadData()
            }
        })
    }
    
    func sortShowsByTimeLeft() {
        
        // sort by dates closest to day
        self.showList.sort {
            tvShow1, tvShow2 in
            
            var (startOrEnd1: String, time1: Int) = self.getDateLabel(tvShow1)
            var (startOrEnd2: String, time2: Int) = self.getDateLabel(tvShow2)
            
            return time1 < time2
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 105
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("watchlistCell", forIndexPath: indexPath) as! WatchlistCell
        
        var tvShow = self.showList[indexPath.row] as PFObject
        
        var (startOrEnd: String, timeLeft: Int) = getDateLabel(tvShow)
        cell.startOrEndDate.text = startOrEnd
        cell.timeLeft.text = "\(timeLeft)"
        
        if startOrEnd.rangeOfString("starts") != nil {
            cell.timeLeft.textColor = UIColor.cyanColor()
            cell.days.textColor = UIColor.cyanColor()
        } else {
            cell.timeLeft.textColor = UIColor.orangeColor()
            cell.days.textColor = UIColor.orangeColor()
        }
        
        cell.showName.text = tvShow["name"] as? String
        
        if let thumbnail = tvShow["posterImage"] as? PFFile {
            cell.coverImage.file = thumbnail
            cell.coverImage.loadInBackground({ (coverImage: UIImage?, error: NSError?) -> Void in
                if error != nil {
                    cell.coverImage.image = coverImage
                }
            })
        }
        
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.backgroundColor = UIColor(red: 0.9, green: 0.93, blue: 0.95, alpha: 1.0)

        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDateLabel(show: PFObject) -> (dateString: String, timeLeft: Int) {
        
        let currentSeason = show["currentSeason"] as! Int
        let seasonStartDate = show["seasonStartDate"] as! NSDate
        let seasonEndDate: NSDate? = show["seasonEndDate"] as! NSDate?
        
        let (dateString, timeLeft) = getDateStringAndTimeLeft(currentSeason, seasonStartDate: seasonStartDate, seasonEndDate: seasonEndDate!)
        
        return (dateString, timeLeft)
    }
    
    func getDateStringAndTimeLeft(currentSeason: Int, seasonStartDate: NSDate, seasonEndDate: NSDate)  -> (dateString: String, timeLeft: Int) {
        
        var dateString = ""
        var timeLeft = 0
        let currentDate = NSDate()
        
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
                timeLeft = dateDifferenceInString(seasonEndDate)
            }
        }
        else if dateComparisionResult == NSComparisonResult.OrderedSame
        {
            dateString = "Season \(currentSeason) starts today"
        }
        
        return (dateString, timeLeft)
    }
    
    func dateDifferenceInString(date: NSDate) -> Int {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeZone = NSTimeZone()
        
        var currentDate = NSDate()
        let currentDateString = dateFormatter.stringFromDate(currentDate)
        currentDate = dateFormatter.dateFromString(currentDateString)!
        
        return date.daysFrom(currentDate)
    }
    
    @IBAction func showActiveShows(sender: AnyObject) {
        
        watchlistBtn.setTitleTextAttributes([ NSForegroundColorAttributeName: UIColor.orangeColor(), NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        archivedBtn.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        
        fetchShowsFromLocalStore()
    }
    
    @IBAction func showEndedShows(sender: AnyObject) {
        archivedBtn.setTitleTextAttributes([ NSForegroundColorAttributeName: UIColor.orangeColor(), NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        watchlistBtn.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        
        fetchShowsFromLocalStore(includeEndedShows: true)
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


