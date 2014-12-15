//
//  APIClientTests.swift
//  APIClientTests
//
//  Created by Hiroki Kato on 2014/12/15.
//  Copyright (c) 2014年 Hatena Inc. All rights reserved.
//

import UIKit
import XCTest

class APIClientTests: XCTestCase {

    var client: APIClient!
    
    override func setUp() {
        super.setUp()
        client = APIClient()
    }
    
    func testStatus() {
        let expectation = expectationWithDescription("Status")
        client.status { (response, error) -> Void in

            println(response)

            XCTAssertNil(error, "error should be nil")
            XCTAssertNotNil(response, "response should not be nil")

            XCTAssertEqual(response!.status!, "good", "status is good")

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in

        })
    }

    func testLastMessage() {
        let expectation = expectationWithDescription("Status")
        client.lastMessage { (response, error) -> Void in

            println(response)

            XCTAssertNil(error, "error should be nil")
            XCTAssertNotNil(response, "response should not be nil")

            XCTAssertEqual(response!.status!, "good", "status is good")

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            
        })
    }

    func testMessages() {
        let expectation = expectationWithDescription("Status")
        client.messages { (response, error) -> Void in

            println(response)

            XCTAssertNil(error, "error should be nil")
            XCTAssertNotNil(response, "response should not be nil")

            XCTAssertEqual(response!.first!.status!, "good", "status is good")

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            
        })
    }
    
}
