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
        
        self.preferredContentSize = CGSize(width: 0, height: 150)        
    }
    
    /**
    *** Function to fetch the watchlist from local data store
    **/
    func fetchWatchlist() {   
        
        var query: PFQuery = PFQuery(className: "TvShow")
        query.whereKey("seasonEndDate", greaterThan: NSDate())
        
        query.orderByAscending("seasonEndDate")
        query.fromLocalDatastore()
        
        query.findObjectsInBackgroundWithBlock({(NSArray shows, NSError error) in
            if error == nil {
                self.watchlist = shows as! [PFObject]
                self.tableView.reloadData()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
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
        
        var tvShow = self.watchlist[indexPath.row] as PFObject
        
        cell.widgetShowName.text = tvShow["name"] as? String
        
        var (startOrEnd: String, timeLeft: Int) = Helper.getDateStringAndTimeLeft(tvShow)
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
        
        // move the UI a little to the left on iphone 4/5 since the width is too small to fit in al the info nicely
        if self.view.frame.width < 375 {
            let newInsets = UIEdgeInsets(top: defaultMarginInsets.top + 10, left: defaultMarginInsets.left - 34,
                bottom: defaultMarginInsets.bottom - 20, right: defaultMarginInsets.right)
            return newInsets
        } else {
            return defaultMarginInsets
        }
    }
    
}
