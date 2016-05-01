//
//  LocationPickerControllerTests.swift
//  LocationPickerControllerTests
//
//  Created by koogawa on 2016/04/30.
//  Copyright © 2016 koogawa. All rights reserved.
//

import XCTest
import CoreLocation

@testable import LocationPickerController

class LocationPickerControllerTests: XCTestCase {
    
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
        let viewController = LocationPickerController(success: {
            (coordinate: CLLocationCoordinate2D) -> Void in
            XCTAssertNotNil(coordinate)
            },
                                                      failure: {
                                                        (error: NSError) -> Void in
                                                        XCTAssertNotNil(error)
        })
        XCTAssertNotNil(viewController)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
