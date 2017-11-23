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
        john = Person(personID: UUID.init(), name: "John Lennon", nick: ("J", "L"))
        paul = Person(personID: UUID.init(), name: "Paul McCartney", nick: ("P", "M"))
        george = Person(personID: UUID.init(), name: "George Harrison", nick: ("G", "H"))
        ringo = Person(personID: UUID.init(), name: "Ringo Starr", nick: (("R", "S")))
        bowling = Event(eventID: UUID.init(), description: "Bowling", date: Date.init(timeIntervalSinceNow: 10), payer: john, participants: [john, paul, ringo, george], amount: 120)
        skiing = Event(eventID: UUID.init(), description: "Skiing at Jackson Hole", date: Date.init(timeIntervalSinceNow: 11), payer: ringo, participants: [george, ringo], amount: 900)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerson() {
        XCTAssertNotEqual(john, george)
        XCTAssertEqual(ringo.nickToString, "RS")
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
        XCTAssertEqual(minValue(bowling.entry)!.1, -30.0)
        XCTAssertEqual(maxValue(skiing.entry)!.1, 450.0)
    }
    
    func testReconcile() {
        XCTAssertEqual((reconcile(total([bowling, skiing]))[1].payment), 60.0)
    }
    
}
