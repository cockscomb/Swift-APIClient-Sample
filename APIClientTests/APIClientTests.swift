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
        client.status { (response) -> Void in

            switch (response) {
            case .One(let status):
                XCTAssertEqual(status().status!, "good", "Status is good")
            default:
                XCTFail("Response must have one status")
            }

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in

        })
    }

    func testLastMessage() {
        let expectation = expectationWithDescription("Last Message")
        client.lastMessage { (response) -> Void in

            switch (response) {
            case .One(let message):
                XCTAssertEqual(message().status!, "good", "Status is good")
            default:
                XCTFail("Response must have one message")
            }

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            
        })
    }

    func testMessages() {
        let expectation = expectationWithDescription("Messages")
        client.messages { (response) -> Void in

            switch (response) {
            case .Many(let messages):
                XCTAssertEqual(messages().first!.status!, "good", "Status is good")
            default:
                XCTFail("Response must have many messages")
            }

            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            
        })
    }

}
