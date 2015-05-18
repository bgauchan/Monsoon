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
    
    @IBOutlet weak var tableview: UITableView!
    
    var showList = [PFObject]()
    
    let defaults = NSUserDefaults(suiteName: "group.com.bardan.monsoon")
    let helper = Helper()
    var shouldFetchFromServer = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableview.separatorColor = UIColor.clearColor()
        self.tableview.backgroundColor = UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1.0)
        
        // Toolbar buttons
        
        watchlistBtn.tintColor = UIColor.orangeColor()
        
        //watchlistBtn.setTitleTextAttributes([ NSForegroundColorAttributeName: UIColor.orangeColor(), NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        //archivedBtn.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        
        helper.checkIfNotificationExists()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // check the last fetched date
        let defaults = NSUserDefaults.standardUserDefaults()
        var currentDate = NSDate()
        
        if let lastFetchedDate = defaults.objectForKey("lastFetchedDate") as? NSDate {
            
            //println("Time since last fetched => \(currentDate.timeIntervalSinceDate(lastFetchedDate))")
            
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
                self.tableview.reloadData()
            }
        })
    }
    
    func sortShowsByTimeLeft() {
        
        // sort by dates closest to day
        self.showList.sort {
            tvShow1, tvShow2 in
            
            var (startOrEnd1: String, time1: Int) = self.helper.getDateStringAndTimeLeft(tvShow1)
            var (startOrEnd2: String, time2: Int) = self.helper.getDateStringAndTimeLeft(tvShow2)
            
            return time1 < time2
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 103
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("watchlistCell", forIndexPath: indexPath) as! WatchlistCell
        
        var tvShow = self.showList[indexPath.row] as PFObject
        
        var (startOrEnd: String, timeLeft: Int) = helper.getDateStringAndTimeLeft(tvShow)
        cell.startOrEndDate.text = startOrEnd
        
        if timeLeft < 10 {
            cell.timeLeft.text = "0\(timeLeft)"
        } else {            
            cell.timeLeft.text = "\(timeLeft)"
        }
        
        // different colors for days left labels depending on if the show is starting or ending
        
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Burn" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            var tvShow = self.showList[indexPath.row] as PFObject
            
            // unpin the show
            tvShow.unpinInBackgroundWithName("watchlist", block: { (success: Bool, error: NSError?) -> Void in
                if success {
                    self.showList.removeAtIndex(indexPath.row) // remove the array
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic) // delete the table row
                    
                    self.helper.removeNotification(tvShow["seriesID"] as! Int) // remove the notification associated with the show
                }
            })
            
        })
        
        deleteAction.backgroundColor = UIColor(red: 0.9, green: 0.93, blue: 0.95, alpha: 1.0)
        
        return [deleteAction]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func showActiveShows(sender: AnyObject) {
        
        watchlistBtn.tintColor = UIColor.orangeColor()
        archivedBtn.tintColor = UIColor.lightGrayColor()
        
        //watchlistBtn.setTitleTextAttributes([ NSForegroundColorAttributeName: UIColor.orangeColor(), NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        //archivedBtn.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        
        fetchShowsFromLocalStore()
    }
    
    @IBAction func showEndedShows(sender: AnyObject) {
        
        archivedBtn.tintColor = UIColor.orangeColor()
        watchlistBtn.tintColor = UIColor.lightGrayColor()
        
        //archivedBtn.setTitleTextAttributes([ NSForegroundColorAttributeName: UIColor.orangeColor(), NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        //watchlistBtn.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        
        fetchShowsFromLocalStore(includeEndedShows: true)
    }
    
    @IBAction func showSettingsView(sender: AnyObject) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
}


