//
//  APILayerDemoTests.swift
//  APILayerDemoTests
//
//  Created by Ole Krause-Sparmann on 11.02.15.
//  Copyright (c) 2015 you & the gang. All rights reserved.
//

import UIKit
import XCTest
import Alamofire

class APILayerDemoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        API.parameterMapper = Mapper()
        API.parameterMapper.dateFormatter = dateFormatter
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGETEndpoint() {
        
        let getExpectation = expectationWithDescription("getExpectation")
        
        API.request(Router.DemoGETRequest(param: "test"), complete: { (items: DemoItems?, error) -> () in
            
            XCTAssertTrue(items != nil, "There was a problem with the returned value from GETEndpoint()")
            
            var report = ""
            let missing = "<missing>"
            
            if let validItems = items {
                report = ""
                
                for item in validItems.items {
                    report = report + "itemId = \(item.itemId ?? missing), title = \(item.title ?? missing)"
                    if let ac = item.awesomeCount {
                        report += ", awesomeCount = \(ac)\n"
                    } else {
                        report += ", awesomeCount = \(missing)\n"
                    }
                }
            }
            else {
                report = "Could not find any items! Error says \(error?.localizedDescription ?? missing)"
            }
            
            println(report)
            
            getExpectation.fulfill()
            
        })
        
        waitForExpectationsWithTimeout(40, handler: { (error: NSError!) -> Void in })
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
