//
//  NoShowsFoundView.swift
//  Monsoon
//
//  Created by Bardan Gauchan on 2015-05-22.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

import UIKit
import Parse

class NoShowsFoundView: UIView {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var requestShowLabel: UILabel!
    @IBOutlet weak var requestShowBtn: UIButton!
    
    // Our custom view from the XIB file
    var view = UIView()
    
    var showName = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let bundle = NSBundle(forClass: self.dynamicType)
        view = bundle.loadNibNamed("NoShowsFoundView", owner: self, options: nil)[0] as! NoShowsFoundView
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        addSubview(view)
        
        requestShowBtn.layer.cornerRadius = 23
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func addLabelForShow() {
        
        let labelText = NSMutableAttributedString(string: "No show named ", attributes: nil)
        
        let show = NSMutableAttributedString(string: showName, attributes: nil)
        show.addAttribute(NSForegroundColorAttributeName, value: UIColor.cyanColor(), range: NSRange(location:0,length:show.length))
        
        labelText.appendAttributedString(show)
        labelText.appendAttributedString(NSAttributedString(string: " was found. Would you like to request this show to be added?"))
        
        requestShowLabel.attributedText = labelText
    }
    
    @IBAction func requestToAddShow(sender: AnyObject) {
        
        // Add the show searched (but not found) as a request in Parse
        if showName.characters.count > 0 {
            let request = PFObject(className: "Request")
            request["tvShow"] = showName
            
            request.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    self.iconView.image = UIImage(named: "request-sent-icon")
                    self.requestShowBtn.backgroundColor = UIColor.cyanColor()
                    self.requestShowBtn.setTitle("Request sent!", forState: UIControlState.Normal)
                    self.requestShowBtn.setTitleColor(UIColor.darkMonsoonColor(), forState: UIControlState.Normal)
                }
            })
        }
    }
    
}
