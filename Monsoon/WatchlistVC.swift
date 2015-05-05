//
//  ViewController.swift
//  Monsoon
//
//  Created by Bardan Gauchan on 2015-05-04.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

import UIKit

class WatchlistVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var hasEnded: UIBarButtonItem!
    @IBOutlet weak var allShows: UIBarButtonItem!
    @IBOutlet weak var yetToStart: UIBarButtonItem!
    
    @IBOutlet weak var watchlist: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.watchlist.registerClass(UITableViewCell.self, forCellReuseIdentifier: "watchlistCell")
        
        hasEnded.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        allShows.setTitleTextAttributes([ NSForegroundColorAttributeName: UIColor.orangeColor(), NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        yetToStart.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Futura", size: 16)!], forState: UIControlState.Normal)
        
        self.watchlist.separatorColor = UIColor.clearColor()
        self.watchlist.backgroundColor = UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("watchlistCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = "Hello Venus!"
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

