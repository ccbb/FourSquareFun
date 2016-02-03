//
//  FSEvent.swift
//  FourSQ101
//
//  Created by Cail Borrell on 01/02/2016.
//  Copyright © 2016 Borrell Consult. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 This class is an object representation of a Four Square event the
 contains the items required by the assignment.
 */

class Venue {
    
    // Current
    enum VenueFields: String {
        case Address  = "address"
        case City     = "city"
        case Distance = "distance"
        case Location = "location"
        case Name     = "name"
    }
    
    let name:     String?
    let address:  String?
    let city:     String?
    let distance: Int?

    // Computed property utility that formats the location info.
    var formattedAddress: String {
        get {
            return address! + ", " + city! + "distance: " + String(distance!) + "m"
        }
    }

    required init(json: JSON) {
        name     = json[VenueFields.Name.rawValue].stringValue
        address  = json[VenueFields.Location.rawValue][VenueFields.Address.rawValue].stringValue
        city     = json[VenueFields.Location.rawValue][VenueFields.City.rawValue].stringValue
        distance = json[VenueFields.Location.rawValue][VenueFields.Distance.rawValue].intValue
    }
    
}