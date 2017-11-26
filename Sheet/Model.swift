//
//  Model.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 11/22/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import Foundation

struct Person: Codable {
    let personID : UUID
    let name : String
    let nick : String
}

extension Person: CustomStringConvertible {
    var description: String {
        return nick
    }
}

extension Person: Equatable {
    static func ==(lhs: Person, rhs: Person) -> Bool {
        let eq =
            lhs.personID == rhs.personID &&
            lhs.name == rhs.name &&
            lhs.nick == rhs.nick
        return eq
    }
}

extension Person: Hashable {
    var hashValue: Int {
        return personID.hashValue
    }
}

let noOne = Person(personID: UUID(), name: "No One", nick: "XX")

typealias Entry = [Person: Double]

struct Event: Codable {
    let eventID: UUID
    let description: String
    let date : Date
    let payer : Person
    let participants : [Person]
    let amount : Double
    
    var entry: Entry {
        let owe = -amount / Double(participants.count)
        var e: Entry = [:]
        for participant in participants {
            e[participant] = owe
        }
        if let payerShare = e[payer] {
            e.updateValue(payerShare + amount, forKey: payer)
        } else {
            e[payer] = amount
        }
        return e
    }
}

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

//typealias Sheet = [Event]
class Sheet: Codable {
    var people = [Person]()
    var events = [Event]()
    
    func deleteEntry(sheet: Sheet, id: UUID) {
        sheet.events = sheet.events.filter({$0.eventID != id})
    }
}

func total(_ sheet: Sheet) -> Entry {
    var result = Entry()
    let entries = sheet.events.map {$0.entry}
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

func extremum<K,V>(comp: @escaping (V, V) -> Bool) -> ([K: V]) -> (K, V)? {
    func ans(_ dict: [K: V]) -> (K, V)? {
        guard dict.count > 0 else {return nil}
        var result: (K, V)! = nil
        for (k, v) in dict {
            if let r = result {
                if comp(v, r.1) {
                    result = (k, v)
                }
            } else {
                result = (k, v)
            }
        }
        return result
    }
    return ans
}

func minValue<K,V:Comparable>(_ dict: [K: V]) -> (K, V)? {
    return extremum(comp: <)(dict)
}

func maxValue<K,V:Comparable>(_ dict: [K: V]) -> (K, V)? {
    return extremum(comp: >)(dict)
}

struct Payment {
    let from : Person
    let to : Person
    let payment : Double
}

func pairOff(_ e: Entry) -> (Payment, Entry)! {
    var ent = e
    if let (f, a) = maxValue(e) {
        if let (t, b) = minValue(e) {
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

func reconcile(_ ent: Entry) -> [Payment] {
    var ent = ent
    var result = [Payment]()
    while ent.count >= 2 {
        if let (p, newEvent) = pairOff(ent) {
            ent = newEvent
            result.append(p)
        } else {
            return [Payment(from: noOne, to: noOne, payment: 0)]
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



