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
    

    func q(_ name: String) -> Person {
        return Person(name: name, email: nil)
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        let p = 20
        let max = 10000
        var pos: [Person:Int] = [:]
        var sgn = 1
        for i in 0..<p {
            if i % 2 == 0 {
                sgn = 1
            } else {
                sgn = -1
            }
            pos.updateValue(1 * sgn + sgn * Int(arc4random_uniform(UInt32(max))), forKey:  q("P\(i)"))
        }
    
        let posSum = pos.values.reduce(0, +)
        pos.updateValue(-posSum, forKey: q("T"))
        let d = pos.mapValues(){Double($0)}
        self.measure {
            print(settle(d).count)

        }
    }
    
}
