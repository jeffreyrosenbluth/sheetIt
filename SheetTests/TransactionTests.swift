//
//  TransactionTests.swift
//  SheetTests
//
//  Created by Jeffrey Rosenbluth on 12/4/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import XCTest
@testable import Sheet

class TransactionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNeighbors() {
//        let ledger = Ledger(positives: [99, 75, 50, 49, 40], negatives: [-65, -50, -49, -10, -25, -25, -29, -20, -20, -10, -10])
        let ledger =  Ledger(positives: [99, 75, 50, 49], negatives: [-65, -50, -49, -10, -25, -25, -29, -20])
        let sol = solve(ledger: ledger)
        print(sol.toArray)
        print(sol.count)
        delta(ledger, sol.toArray[0])
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
