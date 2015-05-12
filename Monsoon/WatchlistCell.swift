//
//  WatchlistCell.swift
//  Monsoon
//
//  Created by Bardan Gauchan on 2015-05-04.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

import UIKit
import ParseUI

class WatchlistCell: UITableViewCell {

    @IBOutlet weak var coverImage: PFImageView!
    @IBOutlet weak var showName: UILabel!
    
    @IBOutlet weak var startOrEndDate: UILabel!
    @IBOutlet weak var timeLeft: UILabel!
    
    @IBOutlet weak var days: UILabel!
}
