//
//  ViewController.swift
//  CodePathYelp
//
//  Created by Ray Ho on 9/17/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    var searchField: UISearchBar!
    @IBOutlet weak var resultTable: UITableView!
    @IBAction func onTouchAnywhere(sender: UIGestureRecognizer) {
        dismissKeyboard()
    }
    var businesses: Array<NSDictionary> = []
    var location: CLLocation! = nil
    var locationManager: CLLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize search field
        searchField = UISearchBar()
        searchField.placeholder = "Search"
        navigationItem.titleView = searchField

        // Listen for search events.
        searchField.delegate = self

        // Initialize filter button
        var filterButton: UIBarButtonItem = UIBarButtonItem(title: "Filter", style: UIBarButtonItemStyle.Plain, target: self, action: "onFilterButtonClicked:")
        filterButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        navigationItem.leftBarButtonItem = filterButton

        // Initialize table view.
        resultTable.dataSource = self
        resultTable.delegate = self
        resultTable.separatorInset = UIEdgeInsetsZero
        resultTable.layoutMargins = UIEdgeInsetsZero

        // Listen for location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            locationManager.startUpdatingLocation()
        }
    }

    override func viewWillAppear(animated: Bool) {
        YELP.search(searchField.text, offset: 0, location: nil, success: onSearchSuccess, failure: onSearchFail)
    }

    override func viewWillDisappear(animated: Bool) {
        // Turn off location when we leave this screen
        locationManager.stopUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func onFilterButtonClicked(sender: AnyObject!) {
        performSegueWithIdentifier("toFiltersSegue", sender: self)
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // Perform search
        YELP.search(searchBar.text, offset: 0, location: location, onSearchSuccess, onSearchFail)

        // Hide keyboard when search button is tapped.
        searchBar.endEditing(true)
    }

    func onSearchSuccess(operation: AFHTTPRequestOperation!, response: AnyObject!) {
        NSLog("Downloaded search results")
        var dictionary: NSDictionary = response as NSDictionary
        self.businesses = dictionary.valueForKey("businesses") as Array
        self.resultTable.reloadData()
    }

    func onSearchSuccessAppend(operation: AFHTTPRequestOperation!, response: AnyObject!) {
        NSLog("Downloaded appended search results")
        var dictionary: NSDictionary = response as NSDictionary
        let addBusinesses: NSArray = dictionary.valueForKey("businesses") as NSArray
        for b in addBusinesses {
            self.businesses.append(b as NSDictionary)
        }
        self.resultTable.reloadData()
    }

    func onSearchFail(operation: AFHTTPRequestOperation!, error: NSError!) {
        // Do nothing for now
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row: Int = indexPath.row as Int
        var cell: UITableViewCell!
        if (row == businesses.count) {  // at end of the list
            let spinnerCell: SpinnerCell = tableView.dequeueReusableCellWithIdentifier("SpinnerCell") as SpinnerCell
            spinnerCell.spinnerView.startAnimating()
            cell = spinnerCell

            // Kick off fetching next set of results
            if (businesses.count > 0) {
                let delay = 2.0 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), {
                    YELP.search(self.searchField.text, offset: self.businesses.count, location: self.location, success: self.onSearchSuccessAppend, failure: self.onSearchFail)
                })
            }
        } else {    // somewhere in the list
            NSLog("Row index: %u, Business count = %u", row, businesses.count)
            let business: NSDictionary = businesses[row] as NSDictionary
            let anyCell: AnyObject? = tableView.dequeueReusableCellWithIdentifier("ResultCell")
            if (anyCell != nil) {
                let resultCell: ResultCell = tableView.dequeueReusableCellWithIdentifier("ResultCell") as ResultCell
                resultCell.populate(business)
                cell = resultCell
            } else {
                cell = UITableViewCell()
            }
        }
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count + 1
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        dismissKeyboard()
    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        manager.startUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let latestLocation: CLLocation = manager.location
        NSLog("Location found: %@", latestLocation)
        if (location == nil) {
            // TODO Location found. Kick off initial search.
            
        }
        self.location = latestLocation
        manager.stopUpdatingLocation()
    }

    func dismissKeyboard() {
        searchField.endEditing(true)
    }

    deinit {
        searchField.delegate = nil
        resultTable.delegate = nil
        locationManager.delegate = nil
    }
}

