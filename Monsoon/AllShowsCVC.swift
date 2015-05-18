//
//  AllShowsCVC.swift
//  Monsoon
//
//  Created by Bardan Gauchan on 2015-05-12.
//  Copyright (c) 2015 Bardan Gauchan. All rights reserved.
//

import UIKit
import Parse

let reuseIdentifier = "tvShowCell"

class AllShowsCVC: UICollectionViewController {
    
    var showList = [PFObject]()
    let helper = Helper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.collectionView?.backgroundColor = UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1.0)
        
        var query: PFQuery = PFQuery(className: "TvShow")
        query.whereKeyExists("coverImage")
        query.orderByDescending("updatedAt")
        
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if error != nil {
                print(error)
            } else {
                self.showList = objects as! [PFObject]
                self.collectionView?.reloadData()
            }
        })
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.showList.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TvShowCell
        
        if let tvShow = self.showList[indexPath.row] as PFObject? {
            var thumbnail = tvShow["coverImage"] as! PFFile
            cell.coverImageView.file = thumbnail
            cell.coverImageView.loadInBackground { (coverImage: UIImage?, error: NSError?) -> Void in
                if error != nil {
                    cell.coverImageView.image = coverImage
                }
            }
        }

    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tvShow = self.showList[indexPath.row] as PFObject
        
        var query: PFQuery = PFQuery(className: "TvShow")
        
        tvShow.pinInBackgroundWithName("watchlist", block: { (success: Bool, error: NSError?) -> Void in
            if success {
                println("Pinning was successful")
                
                // set up a notification for the tv show
                self.helper.scheduleNotification(tvShow)
                
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                print("\nPinning wasn't successful!")
            }
        })
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                withReuseIdentifier:"searchCell", forIndexPath: indexPath) as! UICollectionReusableView
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var width = self.view.frame.size.width/3.0
        var height = self.view.frame.size.width/2.0
        
        return CGSize(width: width - 2, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    @IBAction func closeModal(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showSearchBar(sender: AnyObject) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
