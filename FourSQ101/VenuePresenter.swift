//
//  VenuePresenter.swift
//  FourSQ101
//
//  Created by Cail Borrell on 02/02/2016.
//  Copyright © 2016 Borrell Consult. All rights reserved.
//

import Foundation
import UIKit

// MARK: - VenuePresenterDelegate protocol declaration

protocol VenuePresenterDelegate: class {
    
    func presenter(presenter: VenuePresenter, didReceiveError errorType:ErrorType)
    
}


class VenuePresenter: NSObject {
    
    weak var delegate: protocol<VenuePresenterDelegate>?

    unowned let tableView: UITableView
    
    private let kCellIdentifier = "CellIdentifier"

    // Array containing the fetched venues.
    private var venueArray: [Venue]?

    required init(tableView: UITableView) {
        self.tableView  = tableView
    }

}

// MARK: - Table View DataSource methods

extension VenuePresenter: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath)
        
        if let venue = venueArray?[indexPath.row] {
            cell.textLabel?.text = venue.name
            cell.detailTextLabel?.text = venue.formattedAddress
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venueArray?.count ?? 0
    }
    
}

// MARK: - Search Result Updating Delegate methods

extension VenuePresenter: UISearchResultsUpdating {
    
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
                self.venueArray = result
                self.tableView.reloadData()
                
            case .Error(let error):
                self.delegate?.presenter(self, didReceiveError: error)
            }
        }
    }
}

