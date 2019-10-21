//
//  CoreServiceTests.swift
//  CoreServiceTests
//
//  Created by Rubens Machion on 21/10/19.
//  Copyright © 2019 Rubens Machion. All rights reserved.
//

import XCTest
@testable import CoreService

class CoreServiceTests: XCTestCase {

    var addressService: AddressService!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.addressService = AddressService()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        self.addressService.getSearchZipCode("04055-040",
                                             completion: { address, route, error in
                                                
                                                if let _ = error {
                                                    
                                                    print(error)
                                                } else {
                                                    
                                                    print(address)
                                                }
        })
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
