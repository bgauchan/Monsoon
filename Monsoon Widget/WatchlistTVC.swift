//
//  TodayViewController.swift
//  Monsoon Widget
//
//  Created by Bardan Gauchan on 2015-05-25.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

import UIKit
import NotificationCenter

class WatchlistTVC: UITableViewController, NCWidgetProviding {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 0, height: 50)
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
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("watchlistWidgetCell", forIndexPath: indexPath) as! UITableViewCell
        
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
