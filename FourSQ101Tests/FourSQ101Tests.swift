//
//  FourSQ101Tests.swift
//  FourSQ101Tests
//
//  Created by Cail Borrell on 01/02/2016.
//  Copyright © 2016 Borrell Consult. All rights reserved.
//

import XCTest
import Alamofire
import SwiftyJSON

@testable import FourSQ101

class FourSQ101Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
 
    func testConfigURL() {
        XCTAssertNotEqual(QueryManager.sharedInstance.url, "", "Error - url is not defined")
    }

    func testConfigClientId() {
        XCTAssertNotEqual(QueryManager.sharedInstance.clientId, "", "Error - clientId is not defined")
    }

    func testConfigClientSecret() {
        XCTAssertNotEqual(QueryManager.sharedInstance.clientSecret, "", "Error - clientId is not defined")
    }

    func testRequestAuthentication() {
        let expectation = expectationWithDescription("Alamofire")
        
        Alamofire.request(.GET, QueryManager.sharedInstance.url!, parameters: QueryManager.generalParameters() ).response {
            request, response, data, error in
            
                XCTAssertNil(error, "Whoops, error \(error)")
                
                XCTAssertEqual(response?.statusCode, 200, "Error - Status code not 200")
                
                expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testVenueInitializationWithValues() {
        let name     = "VenueName"
        let address  = "VenueAddress"
        let city     = "VenueAddress"
        let distance = "100"
        
        let jsonVenue = JSON(["name": name, "location": ["address": address, "city": city, "distance": distance]])
        
        let venue = Venue(json: jsonVenue)

        XCTAssertEqual(venue.name, name, "Error - name is not correct")
        XCTAssertEqual(venue.address, address, "Error - address is not correct")
        XCTAssertEqual(venue.city, city, "Error - city is not correct")
        XCTAssertEqual(venue.distance, Int(distance), "Error - city is not correct")
    }

    func testVenueInitializationWithoutValues() {
        let name     = ""
        let address  = ""
        let city     = ""
        let distance = ""
        
        let jsonVenue = JSON(["name": name, "location": ["address": address, "city": city, "distance": distance]])
        
        let venue = Venue(json: jsonVenue)
        
        XCTAssertEqual(venue.name, name, "Error - name is not correct")
        XCTAssertEqual(venue.address, address, "Error - address is not correct")
        XCTAssertEqual(venue.city, city, "Error - city is not correct")
        XCTAssertEqual(venue.distance, 0, "Error - city is not correct")
    }

}
