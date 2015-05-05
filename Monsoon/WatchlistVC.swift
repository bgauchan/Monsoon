//
//  ViewController.swift
//  Monsoon
//
//  Created by Bardan Gauchan on 2015-05-04.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

import UIKit

class WatchlistVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var watchlist: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.watchlist.registerClass(UITableViewCell.self, forCellReuseIdentifier: "watchlistCell")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
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

