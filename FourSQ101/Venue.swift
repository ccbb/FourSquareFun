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

    // Computed property utility that formats the location info.
    var formattedAddress: String {
        get {
            return address! + ", " + city! + "distance: " + String(distance!) + "m"
        }
    }
    
    var name:     String?
    var address:  String?
    var city:     String?
    var distance: Int?

    required init(json: JSON) {
        name     = json[VenueFields.Name.rawValue].stringValue
        address  = json[VenueFields.Location.rawValue][VenueFields.Address.rawValue].stringValue
        city     = json[VenueFields.Location.rawValue][VenueFields.City.rawValue].stringValue
        distance = json[VenueFields.Location.rawValue][VenueFields.Distance.rawValue].intValue
    }
    
}