//
//  NoShowsFoundView.swift
//  Monsoon
//
//  Created by Bardan Gauchan on 2015-05-22.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

import UIKit

class NoShowsFoundView: UIView {
    
    @IBOutlet weak var requestShowLabel: UILabel!
    @IBOutlet weak var requestShowBtn: UIButton!
    
    // Our custom view from the XIB file
    var view = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let bundle = NSBundle(forClass: self.dynamicType)
        view = bundle.loadNibNamed("NoShowsFoundView", owner: self, options: nil)[0] as! NoShowsFoundView
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        addSubview(view)
        
        requestShowBtn.layer.cornerRadius = 20
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func addLabelFor(#show: String) {
        
        var labelText = NSMutableAttributedString(string: "No show named ", attributes: nil)
        
        var show = NSMutableAttributedString(string: show, attributes: nil)
        show.addAttribute(NSForegroundColorAttributeName, value: UIColor.cyanColor(), range: NSRange(location:0,length:show.length))
        
        labelText.appendAttributedString(show)
        labelText.appendAttributedString(NSAttributedString(string: " was found. Would you like to request this show to be added?"))
        
        requestShowLabel.attributedText = labelText
        
    }
}
