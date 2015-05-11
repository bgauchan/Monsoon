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
    
    func fetchShowsFromLocalStore() {
        
        var query: PFQuery = PFQuery(className: "TvShow")
        query.orderByAscending("seasonEndDate")
        //query.fromLocalDatastore()
        
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if error != nil {
                print(error)
            } else {
                self.showList = objects as! [PFObject]
                //self.sortShowsByTimeLeft()
                self.watchlist.reloadData()
            }
        })
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 105
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.showList.count
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("watchlistCell", forIndexPath: indexPath) as! WatchlistCell
        
        //var tvShow = self.showList[indexPath.row] as PFObject
        //cell.textLabel?.text = tvShow["name"] as? String
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.backgroundColor = UIColor(red: 0.9, green: 0.93, blue: 0.95, alpha: 1.0)

        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

