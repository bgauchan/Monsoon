//
//  TodayViewController.swift
//  Monsoon Widget
//
//  Created by Bardan Gauchan on 2015-05-25.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

import UIKit
import NotificationCenter
import Parse

class WatchlistTVC: UITableViewController, NCWidgetProviding {
    
    var watchlist = [PFObject]()
    
    let defaults = NSUserDefaults(suiteName: "group.com.bardan.monsoon")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Parse Setup
        Parse.enableLocalDatastore()
        
        // Enable data sharing in main app.
        Parse.enableDataSharingWithApplicationGroupIdentifier("group.com.bardan.monsoon", containingApplication: "Bardan-Gauchan.Monsoon")
        
        // Setup Parse
        Parse.setApplicationId("IP1rs5my0SYAbjLLUksy2D83vTWQGnNh2xp1Frsb",
            clientKey: "eeEM2IgofWFTRmYe4F62UoOLNQq8Tf63IUU7gsq9")
        
        fetchWatchlist()
    }
    
    /**
    *** Function to fetch the watchlist from local data store
    **/
    func fetchWatchlist() {   
        
        let query: PFQuery = PFQuery(className: "TvShow")
        query.whereKey("seasonEndDate", greaterThan: NSDate())
        
        query.limit = 8
        query.fromLocalDatastore()
        
        query.findObjectsInBackgroundWithBlock({(NSArray shows, NSError error) in
            if error == nil {
                self.watchlist = shows as! [PFObject]
                self.sortShowsByTimeLeft()
                
                while self.watchlist.count > 5 {
                    self.watchlist.removeLast()
                }
                
                self.tableView.reloadData()
                self.updateWidget()
            }
        })
    }
    
    func updateWidget() {
        
        var tableHeight = self.watchlist.count * 50
        
        if tableHeight < 1 {
            tableHeight = 10
        }
        
        self.preferredContentSize = CGSize(width: 0, height: tableHeight)
    }
    
    func sortShowsByTimeLeft() {
        
        // sort by dates closest to day
        self.watchlist.sortInPlace {
            tvShow1, tvShow2 in
            
            let (_, time1): (String, Int) = Helper.getDateStringAndTimeLeft(tvShow1)
            let (_, time2): (String, Int) = Helper.getDateStringAndTimeLeft(tvShow2)
            
            return time1 < time2
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        if let widgetShouldUpdate = defaults.objectForKey("shouldWidgetUpdate") as? Bool  {
            print("update process starting..")
            if widgetShouldUpdate {
                
                print("updating view due to widgetShouldUpdate")
                
                defaults.setObject(false, forKey: "shouldWidgetUpdate")
                defaults.synchronize()
                
                completionHandler(NCUpdateResult.NewData)
            } else {
                completionHandler(NCUpdateResult.NoData)
            }            
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.watchlist.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("watchlistWidgetCell", forIndexPath: indexPath) as! WatchlistCell
        
        let tvShow = self.watchlist[indexPath.row] as PFObject
        
        cell.widgetShowName.text = tvShow["name"] as? String
        
        let (startOrEnd, timeLeft): (String, Int) = Helper.getDateStringAndTimeLeft(tvShow)
        cell.widgetCurrentSeason.text = startOrEnd
        
        if timeLeft >= 0 && timeLeft < 10 {
            cell.widgetTimeLeft.text = "0\(timeLeft)"
        } else {
            cell.widgetTimeLeft.text = "\(timeLeft)"
        }
        
        // different colors for days left labels depending on if the show is starting or ending
        
        if startOrEnd.rangeOfString("starts") != nil {
            cell.widgetTimeLeft.textColor = UIColor.cyanColor()
            cell.widgetDays.textColor = UIColor.cyanColor()
        } else {
            cell.widgetTimeLeft.textColor = UIColor.orangeColor()
            cell.widgetDays.textColor = UIColor.orangeColor()
        }
        
        if let thumbnail = tvShow["thumbnail"] as? PFFile {
            cell.widgetCoverImageView.file = thumbnail
            cell.widgetCoverImageView.loadInBackground({ (coverImage: UIImage?, error: NSError?) -> Void in
                if error != nil {
                    cell.widgetCoverImageView.image = coverImage
                }
            })
        }
        
        return cell
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        let newInsets = UIEdgeInsets(top: defaultMarginInsets.top + 10, left: defaultMarginInsets.left - 34,
            bottom: defaultMarginInsets.bottom - 20, right: defaultMarginInsets.right)
        return newInsets
    }
    
}
