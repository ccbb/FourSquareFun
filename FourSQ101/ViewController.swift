//
//  ViewController.swift
//  FourSQ101
//
//  Created by Cail Borrell on 01/02/2016.
//  Copyright © 2016 Borrell Consult. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    private let kCellIdentifier = "CellIdentifier"

    // Controller used to apply search results.
    private let searchController = UISearchController(searchResultsController: nil)

    // Array containing the fetched venues.
    private var eventArray: [Venue]?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Four Square Venues"
        
        definesPresentationContext = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false

        tableView.tableHeaderView = searchController.searchBar
    }
    
    // MARK: - Table View DataSource methods

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath)
        
        if let event = eventArray?[indexPath.row] {
            cell.textLabel?.text = event.name
            cell.detailTextLabel?.text = event.formattedAddress
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray?.count ?? 0
    }

}

// MARK: - Search Result Updating Delegate methods

extension ViewController: UISearchResultsUpdating {
    
    /**
     Search controller updates will trigger Four Square queries.
     */
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // We need to make sure we have at least one character in the query.
        guard let query = searchController.searchBar.text where query.characters.count > 0 else { return }
        
        QueryManager.getVenues(query) { response in
            switch response {
            case .Ok(let result):
                // The response is good and we can use the result
                self.eventArray = result
                self.tableView.reloadData()
                
            case .Error:
                // We are in trouble so we show an alert and reset the query.
                let alertController = UIAlertController(title: "Error", message: "Your're in trouble", preferredStyle: .Alert)
                
                let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in
                    searchController.searchBar.text = ""
                }
                
                alertController.addAction(dismissAction)
                
                self.presentViewController(alertController, animated: true) {}
            }
        }
    }
}
