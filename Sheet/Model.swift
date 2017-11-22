//
//  Model.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 11/22/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import Foundation

struct Person {
    let perosonID : UUID
    let name : String
    let nick : (Character, Character)
    
    func nickToString() -> String {
        let (a, b) = nick
        return String([a, b])
    }
}

extension Person : Equatable {
    static func ==(lhs: Person, rhs: Person) -> Bool {
        let eq =
            lhs.perosonID == rhs.perosonID &&
            lhs.name == rhs.name &&
            lhs.nick == rhs.nick
        return eq
    }
}

struct Event {
    let eventID: UUID
    let description: String
    let date : Date
    let payer : Person
    let participants : [Person]
    let amount : Double
    
    var entry: Entry {
        let owe = -amount / Double(participants.count)
        var e = [eventID: amount]
        for participant in participants {
            e[participant.perosonID] = owe
        }
        return e
    }
}

typealias Entry = [UUID: Double]

extension Event : Equatable {
    static func ==(lhs: Event, rhs: Event) -> Bool {
        let eq =
            lhs.eventID == rhs.eventID &&
            lhs.description == rhs.description &&
            lhs.date == rhs.date &&
            lhs.payer == rhs.payer &&
            lhs.participants == rhs.participants &&
            lhs.amount == rhs.amount
        return eq
    }
}

typealias Sheet = [Event]

func deleteEntry(sheet: Sheet, id: UUID) -> Sheet {
    return sheet.filter {$0.eventID != id}
}

func total(_ sheet: Sheet) -> Entry {
    var result = Entry()
    let entries = sheet.map {$0.entry}
    for e in entries {
        for (key, value) in e {
            if let v = result[key] {
                result.updateValue(v + value, forKey: key)
            } else {
                result[key] = value
            }
        }
    }
    return result
}

func extremum<K,V>(comp: @escaping (V, V) -> Bool) -> ([K: V]) -> (K, V)! {
    func ans(dict: [K: V]) -> (K, V)! {
        guard dict.count > 0 else {return nil}
        var result: (K, V)! = nil
        for (k, v) in dict {
            if let r = result {
                if comp(v, r.1) {
                    result = (k, v)
                }
            }
        }
        return result
    }
    return ans
}

func minValue<K,V:Comparable>(dict: [K: V]) -> (K, V)! {
    return extremum(comp: <)(dict)
}

func maxValue<K,V:Comparable>(dict: [K: V]) -> (K, V)! {
    return extremum(comp: >)(dict)
}

struct Payment {
    let from : UUID
    let to : UUID
    let payment : Double
}

func pairOff(e: Entry) -> (Payment, Entry)! {
    var ent = e
    if let (f, a) = maxValue(dict: e) {
        if let (t, b) = minValue(dict: e) {
            if a >= abs(b) {
                ent.updateValue(e[f]! + b, forKey: f)
                ent.removeValue(forKey: t)
                return (Payment(from: t, to: f, payment: -b), ent)
            } else {
                ent.removeValue(forKey: f)
                ent.updateValue(e[t]! + a, forKey: t)
                return (Payment(from:t, to: f, payment: a), ent)
            }
        }
    }
    return nil
}

enum Impossible: Error {
    case impossible
}

func reconcile(e: Entry)  throws -> [Payment]{
    var ent = e
    var result = [Payment]()
    while ent.count >= 2 {
        if let (p, newEvent) = pairOff(e: ent) {
            ent = newEvent
            result.append(p)
        } else {
            throw Impossible.impossible
        }
    }
    return result
}

extension Payment : Equatable {
    static func ==(lhs: Payment, rhs: Payment) -> Bool {
        let eq =
            lhs.from == rhs.from &&
            lhs.to == rhs.to &&
            lhs.payment == rhs.payment
        return eq
    }
}



