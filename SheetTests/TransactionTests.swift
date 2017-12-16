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
        let ledger: Ledger<String> = Ledger(positives: ["A":99, "B":75, "C":50, "D":49, "E":40],
                            negatives: ["F":65, "G":50, "H":49, "I":10, "J":25, "K":25, "L":29, "M":20, "N":20, "O":10, "P":10],
                            trx: nil)
        let sol = solve(comp: fastOrder, ledger: ledger)
        print(sol.toArray.map({$0.trx}))
        print(sol.count)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        let p = 3
        let n = 4
        let max = 10000
        var pos: [String:Int] = [:]
        var neg: [String:Int] = [:]
        for i in 0..<p {
            pos.updateValue(1 + Int(arc4random_uniform(UInt32(max))), forKey: "P\(i)")
        }
        for j in 0..<n {
            neg.updateValue(1 + Int(arc4random_uniform(UInt32(max))), forKey: "N\(j)")
        }
        let posSum = pos.values.reduce(0, +)
        let negSum = neg.values.reduce(0, +)
        if posSum > negSum {
            neg.updateValue(-neg.values.reduce(0, +) + pos.values.reduce(0, +), forKey: "N\(n)")
        } else {
            pos.updateValue(neg.values.reduce(0, +) - pos.values.reduce(0, +), forKey: "N\(n)")
        }
        print(pos)
        print(neg)
        self.measure {
            print(solve(comp: astarOrder, ledger: Ledger<String>(positives: pos, negatives: neg, trx: nil)).count)
        }
    }
    
}
