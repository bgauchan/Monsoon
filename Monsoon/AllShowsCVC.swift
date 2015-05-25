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

class AllShowsCVC: UICollectionViewController, UISearchBarDelegate {
    
    var showList = [PFObject]()
    let helper = Helper()
    
    var isSearchResultsShown = false // whether the results shown are all shows or searched
    var noShowsFoundView = NoShowsFoundView() // a view to show when no results is found

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.darkMonsoonColor()
        
        fetchShows()
    }
    
    func fetchShows(searchTerm: String? = nil) {
        
        var query: PFQuery = PFQuery(className: "TvShow")
        query.whereKeyExists("coverImage")
        query.orderByDescending("updatedAt")
        
        if searchTerm != nil {
            query.whereKey("name", matchesRegex: searchTerm!, modifiers: "i") // makes the query non-case sensitive
        }
        
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if error != nil {
                print(error)
            } else {
                self.showList = objects as! [PFObject]
                self.collectionView?.reloadData()
                
                if self.showList.count < 1 {
                    self.addNoShowsFoundView(searchTerm!)
                }
            }
        })
    }
    
    func addNoShowsFoundView(showName: String) {
        let xCoordinate = self.view.frame.width * 0.05
        let width = self.view.frame.width * 0.90
        
        noShowsFoundView = NoShowsFoundView(frame: CGRectMake(xCoordinate, 60, width, 350))
        noShowsFoundView.showName = showName
        noShowsFoundView.addLabelForShow()
        
        self.collectionView!.addSubview(noShowsFoundView)
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.showList.count > 0 {
            noShowsFoundView.removeFromSuperview()
        }
        
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
                withReuseIdentifier:"searchCell", forIndexPath: indexPath) as! SearchBarCell
            
            headerView.searchbar.delegate = self
            
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
    
    // Search Bar Delegate Methods
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        isSearchResultsShown = true
        fetchShows(searchTerm: searchBar.text)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if count(searchText) == 0 && isSearchResultsShown {
            fetchShows()
            isSearchResultsShown = false
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        println("cancel")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
