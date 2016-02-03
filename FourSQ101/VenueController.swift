//
//  ViewController.swift
//  FourSQ101
//
//  Created by Cail Borrell on 01/02/2016.
//  Copyright © 2016 Borrell Consult. All rights reserved.
//

import UIKit

class VenueController: UIViewController {

    @IBOutlet var tableView: UITableView! {
        didSet {
            definesPresentationContext = true
            
            searchController.searchResultsUpdater = presenter
            searchController.dimsBackgroundDuringPresentation = false
            
            tableView.dataSource = presenter
            tableView.tableHeaderView = searchController.searchBar
        }
    }
    
    // Controller used to apply search results.
    private lazy var searchController: UISearchController = {
        return UISearchController(searchResultsController: nil)
    }()
    
    // Presenter that handles content updates.
    private lazy var presenter: VenuePresenter = {
        return VenuePresenter(tableView: self.tableView)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
}

extension VenueController: VenuePresenterDelegate {

    func presenter(presenter: VenuePresenter, didReceiveError errorType: ErrorType) {
        // We are in trouble so we show an alert and reset the query.
        let alertController = UIAlertController(title: "Error", message: "Your're in trouble", preferredStyle: .Alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in
            self.searchController.searchBar.text = ""
        }
        
        alertController.addAction(dismissAction)
        
        self.presentViewController(alertController, animated: true) {}
    }
}