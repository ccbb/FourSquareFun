
//
//  QueryManager.swift
//  FourSQ101
//
//  Created by Cail Borrell on 01/02/2016.
//  Copyright © 2016 Borrell Consult. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON

// Defines a global return type. Used to handle positive or negative
// responses. Each with the associated result or error type
enum Result<T> {
    case Ok(T)
    case Error(ErrorType)
    
    init(_ value: T) {
        self = .Ok(value)
    }
    
    init(_ error: ErrorType) {
        self = .Error(error)
    }
}

enum RequestError: ErrorType {
    case InvalidResponse
    case MissingURL
}

enum ParseError: ErrorType {
    case MissingClientId
    case MissingClientSecret
    case MissingLocation
}

/**
 The location manager class detects the current location of device.
 */
class QueryManager: NSObject {
    
    // MARK: - Configuration Initialization and Handling

    // Load the config file
    private lazy var config: Dictionary<String,String> = {
        var config = Dictionary<String,String>()
        
        if let path = NSBundle.mainBundle().pathForResource("FourSquare", ofType: "plist") {
            config = NSDictionary(contentsOfFile: path) as! Dictionary<String,String>
        }

        return config
    }()
 
    var url: String? {
        return config["url"]
    }

    var clientId: String? {
        return config["clientId"]
    }

    var clientSecret: String? {
        return config["clientSecret"]
    }

    // MARK: - Location Manager Initialization

    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        return locationManager
    }()
    
    // MARK: - Four Square parameter utilities
    
    // Utility method to format the coordinate query parameter
    private var formattetCoordinate: String? {
        guard let latitude = latitude, longitude = longitude else {
            // If the values have not been set we do not return a value
            return .None
        }
        
        return String(format: "%f, %f", arguments: [latitude,longitude])
    }
    
    // Utility method to format the version query parameter
    private var formattetDate: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        return formatter.stringFromDate(NSDate())
    }

    // MARK: - Private properties

    private var latitude:  CLLocationDegrees?
    private var longitude: CLLocationDegrees?
    
    // Create a singleton class to handle the location information.
    class var sharedInstance : QueryManager {
        struct Singleton {
            static let instance = QueryManager()
        }
        
        return Singleton.instance
    }
    
    func setupLocationService() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    // MARK: - Four Square query methods
    
    /**
    Method checks and creates the general parameter list.
    
    - throws:  The ParseError if any parameters are missing.
    - returns: The formattet parameters.
    */
    class func generalParameters() throws -> Dictionary<String,String> {
        guard let clientId = QueryManager.sharedInstance.clientId else {
            throw ParseError.MissingClientId
        }
        
        guard let clientSecret = QueryManager.sharedInstance.clientSecret else {
            throw ParseError.MissingClientSecret
        }
        
        guard let ll = QueryManager.sharedInstance.formattetCoordinate else {
            throw ParseError.MissingLocation
        }
        
        return [
            "client_id"    : clientId,
            "client_secret": clientSecret,
            "v"            : QueryManager.sharedInstance.formattetDate,
            "ll"           : ll
        ]
    }
    
    /**
     Method performs a query for venues throught the Four Square API.
     
     - parameter query: is the new query string.
     - parameter completionHandler: is the closure that is called upon error or completion.
     */
    class func getVenues(query: String, completionHandler: (Result<Array<Venue>>) -> Void) {
        
        // Check that we have an URL
        guard let url = QueryManager.sharedInstance.url else {
            completionHandler(Result(RequestError.MissingURL))
            return
        }
        
        do {
            // Check that we have all the parameters we need
            var parameters = try generalParameters()
            
            // Add the new query to the list of parameters
            parameters["query"] = query
            
            Alamofire.request(.GET, url, parameters: parameters).responseJSON { (responseData) -> Void in
                
                // Check that we have an response
                guard let responseValue = responseData.result.value else {
                    completionHandler(Result(RequestError.InvalidResponse))
                    return
                }
                
                // Check that the response has the expected structure
                guard let jsonResult = JSON(responseValue)["response"]["venues"].array  else {
                    completionHandler(Result(RequestError.InvalidResponse))
                    return
                }
                
                // Convert the json to the Venue objects
                let venues = jsonResult.map{ Venue(json: $0) }
                
                completionHandler(Result(venues))
            }

        }
        catch ParseError.MissingClientId {
            completionHandler(Result(ParseError.MissingClientId))
        }
        catch ParseError.MissingClientSecret {
            completionHandler(Result(ParseError.MissingClientSecret))
        }
        catch ParseError.MissingLocation {
            completionHandler(Result(ParseError.MissingLocation))
        }
        catch {
            print("Something else wrong!")
        }
    }
}

// MARK: - Location Manager Delegate methods

extension QueryManager: CLLocationManagerDelegate {
    
    /**
     Delegate method is called in case of a core location error.
     */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        
        print(error)
    }
    
    /**
     Delegate method is called when new data is received.
     */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            latitude = coordinate.latitude
            longitude = coordinate.longitude
        }
    }
    
    /**
     Delegate method is called when authorization status changes.
     */
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Restricted:
            print("Restricted access")
        case .Denied:
            print("Denied access")
        case  .NotDetermined:
            print("NotDetermined access")
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            // Start location services
            locationManager.startUpdatingLocation()
            print("Accepted access: \(status.rawValue)")
        }
    }
    
}