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
import Bolts

class WatchlistVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var watchlistBtn: UIBarButtonItem!
    @IBOutlet weak var archivedBtn: UIBarButtonItem!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var tableview: UITableView!
    
    var watchlist = [PFObject]()
    
    let defaults = NSUserDefaults(suiteName: "group.com.bardan.monsoon")!
    let helper = Helper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        watchlistBtn.tintColor = UIColor.orangeColor()
        
        helper.checkIfNotificationExists()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        var currentDate = NSDate()
        
        if let lastFetchedDate = defaults.objectForKey("lastFetchedDate") as? NSDate {
            
            //println("Time since last fetched => \(currentDate.timeIntervalSinceDate(lastFetchedDate))")
            
            // only fetch from the server if it's been more than an hour
            if currentDate.timeIntervalSinceDate(lastFetchedDate) > 3600 {
                
                var query: PFQuery = PFQuery(className: "TvShow")
                query.fromLocalDatastore()
                
                query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
                    
                    if objects!.count > 0 {
                        let shows = objects as! [PFObject]
                        var seriesIdArray = shows.map { $0.objectForKey("seriesID")! }
                        self.updateWatchlist(seriesIdArray) // update these pinned shows based on their series ID
                    }
                })
                
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
        
        fetchWatchlist()
    }
    
    /** 
    *** Function to fetch the watchlist from local data store
    **/
    func fetchWatchlist(includeEndedShows: Bool? = nil) {     // bool? = nil lets us declare optional paramteres
        
        var query: PFQuery = PFQuery(className: "TvShow")
        
        // whether to show the ended tv shows based on tab
        if includeEndedShows == nil {
            query.whereKey("seasonEndDate", greaterThan: NSDate())
        } else {
            query.whereKey("seasonEndDate", lessThanOrEqualTo: NSDate())
        }
        
        query.orderByAscending("seasonEndDate")
        query.fromLocalDatastore()
        
        query.findObjectsInBackgroundWithBlock({(NSArray shows, NSError error) in
            if error == nil {
                self.watchlist = shows as! [PFObject]
                self.sortShowsByTimeLeft()
                self.tableview.reloadData()
            }
        })
    }
    
    /**
    *** Function to update the watchlist with new data from server.
    *** The method is sent an array of series ID that are locally saved/pinned and it uses these series ID to
    *** query Parse to get the shows with updated info. Once we get them, we first unpin all shows and then we pin
    *** the new ones received. Hence, updating the pinned/saved shows.
    **/
    func updateWatchlist(seriesIdArray:NSArray) {
        
        var query: PFQuery = PFQuery(className: "TvShow")
        query.whereKey("seriesID", containedIn: seriesIdArray as Array <AnyObject>)

        // Query for new results from the network
        query.findObjectsInBackground().continueWithSuccessBlock({
            (task: BFTask!) -> AnyObject! in
            
            return PFObject.unpinAllObjectsInBackgroundWithName("watchlist").continueWithSuccessBlock({
                (ignored: BFTask!) -> AnyObject! in
                
                // Cache new results
                let shows = task.result as? NSArray
                return PFObject.pinAllInBackground(shows as [AnyObject]?, withName: "watchlist").continueWithSuccessBlock({
                    (ignored: BFTask!) -> AnyObject! in
                    
                    self.fetchWatchlist() // once the pinning is done, refresh the view by fetching again
                    return nil
                })
            })
        })
    }
    
    func sortShowsByTimeLeft() {
        
        // sort by dates closest to day
        self.watchlist.sort {
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
        return self.watchlist.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("watchlistCell", forIndexPath: indexPath) as! WatchlistCell
        
        var tvShow = self.watchlist[indexPath.row] as PFObject
        
        var (startOrEnd: String, timeLeft: Int) = helper.getDateStringAndTimeLeft(tvShow)
        cell.startOrEndDate.text = startOrEnd
        
        if timeLeft >= 0 && timeLeft < 10 {
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
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Burn" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            var tvShow = self.watchlist[indexPath.row] as PFObject
            
            // unpin the show
            tvShow.unpinInBackgroundWithName("watchlist", block: { (success: Bool, error: NSError?) -> Void in
                if success {
                    self.watchlist.removeAtIndex(indexPath.row) // remove the array
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
        
        fetchWatchlist()
    }
    
    @IBAction func showEndedShows(sender: AnyObject) {
        
        archivedBtn.tintColor = UIColor.orangeColor()
        watchlistBtn.tintColor = UIColor.lightGrayColor()
        
        fetchWatchlist(includeEndedShows: true)
    }
    
    @IBAction func showSettingsView(sender: AnyObject) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        if !self.watchlist.isEmpty {
            
            PFObject.unpinAllInBackground(self.watchlist, withName: "watchlist", block: { (success: Bool, error: NSError?) -> Void in
                if success {
                    print("Cleared all shows...\n")
                } else {
                    print("Unpin unsuccessful \n")
                }
            })
            
            watchlist.removeAll(keepCapacity: true)
            self.tableview.reloadData()
        }
    }
}


