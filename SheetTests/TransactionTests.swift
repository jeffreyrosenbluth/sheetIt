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
    
    func testPowerset() {
        let set = [1,2,3]
        let ps = powerSet(set)
        print(set)
        print(ps)
        let ips = indexedPowerSet(ps, 3)
        print(ips)
    }
    
    func testSummands() {
        print(summands(5))
    }
    
    func q(_ name: String) -> Person {
        return Person(name: name, email: nil)
    }
    
    func testTrxs() {
        func p(_ name: String) -> Person {
            return Person(name: name, email: nil)
        }
        let ledger: Ledger<Person> = Ledger<Person>(positives: [p("A"):99, p("B"):75, p("C"):50, p("D"):49, p("E"):40],
                                            negatives: [p("F"):65, p("G"):50, p("H"):49, p("I"):10, p("J"):25, p("K"):25, p("L"):29, p("M"):20, p("N"):20, p("O"):10, p("P"):10],
                                            trx: nil)
        let r = reconcileLedgerOpt(ledger)
        print(r)
        print(r.count)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        let p = 7
        let n = 7
        let max = 10000
        var pos: [Person:Int] = [:]
        var neg: [Person:Int] = [:]
        for i in 0..<p {
            pos.updateValue(1 + Int(arc4random_uniform(UInt32(max))), forKey:  q("P\(i)"))
        }
        for j in 0..<n {
            neg.updateValue(1 + Int(arc4random_uniform(UInt32(max))), forKey: q("N\(j)"))
        }
        let posSum = pos.values.reduce(0, +)
        let negSum = neg.values.reduce(0, +)
        if posSum > negSum {
            neg.updateValue(-neg.values.reduce(0, +) + pos.values.reduce(0, +), forKey: q("P\(n)"))
        } else {
            pos.updateValue(neg.values.reduce(0, +) - pos.values.reduce(0, +), forKey: q("N\(n)"))
        }
        print(pos)
        print(neg)
        self.measure {
            print(reconcileLedgerOpt(Ledger<Person>(positives: pos, negatives: neg, trx: nil)).count)
//            print(solve(comp: astarOrder, ledger: Ledger<String>(positives: pos, negatives: neg, trx: nil)).count)

        }
    }
    
}
