//
//  ModelTests.swift
//  SheetTests
//
//  Created by Jeffrey Rosenbluth on 11/22/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import XCTest
@testable import Sheet

class ModelTests: XCTestCase {
    var john: Person!
    var paul: Person!
    var george: Person!
    var ringo: Person!
    var bowling: Event!
    var skiing: Event!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerson() {
        XCTAssertNotEqual(john, george)
//        XCTAssertEqual(ringo.nick, "RS")
    }
    
    func testEntry() {
        var a = 0.0
        for (_, v) in bowling.entry {
            a += v
        }
        XCTAssertEqual(round(100 * a), 0)
        XCTAssertEqual(bowling.entry.count, 4)
    }
    
    func testExtremeum() {
//        XCTAssertEqual(minValue(bowling.entry)!.1, -30.0)
//        XCTAssertEqual(maxValue(skiing.entry)!.1, 450.0)
    }
    
 
    func testCombDict() {
        func p(_ name: String) -> Person {
            return Person(name: name, email: nil)
        }
        let entry = [p("A"):99.0, p("B"):75.0, p("C"):50.0, p("D"):49.0, p("E"):40.0,
                     p("F"):-65.0, p("G"):-50.0, p("H"):-49.0, p("I"):-10.0, p("J"):-25.0, p("K"):-25.0, p("L"):-29.0, p("M"):-20.0, p("N"):-20.0, p("O"):-10.0, p("P"):-10.0]
        let r = settle(entry)
        print(r)
    }
    
}
