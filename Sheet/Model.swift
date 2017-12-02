//
//  Model.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 11/22/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import Foundation

struct Person: Codable {
    let name : String
    let email : String?
}

extension Person: Equatable {
    static func ==(lhs: Person, rhs: Person) -> Bool {
        let eq =
            lhs.name == rhs.name &&
            lhs.email == rhs.email
        return eq
    }
}

extension Person: Hashable {
    var hashValue: Int {
        return name.hashValue
    }
}

let noOne = Person(name: "No One", email: nil)

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
    
    var valid: Bool {
        if description == "" || amount <= 0 || participants == [] {
            return false
        } else {
            return true
        }
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

struct Payment {
    let from : Person
    let to : Person
    let payment : Double
}

func pairs<K,V: Equatable>(pos: [K:V], neg: [K:V]) -> [(K, K)] {
    var result: [(K,K)] = []
    for (k, v) in pos {
        if let r = neg.first(where: {$0.value == v}) {
            result.append((k, r.0))
        }
    }
    return result
}

func randPair(_ e: (Entry, Entry)) -> (Payment, (Entry, Entry))? {
    var (pos, neg) = e
    let negIdx = Int(arc4random_uniform(UInt32(neg.count)))
    let posIdx = Int(arc4random_uniform(UInt32(pos.count)))
    let negKey = Array(neg.keys)[negIdx]
    let posKey = Array(pos.keys)[posIdx]
    guard let a = pos[posKey] else {return nil}
    guard let b = neg[negKey] else {return nil}
    if a == abs(b) {
        neg.removeValue(forKey: negKey)
        pos.removeValue(forKey: posKey)
        return (Payment(from: negKey, to: posKey, payment: -b), (pos, neg))
    } else if a > abs(b) {
        pos.updateValue(pos[posKey]! + b, forKey: posKey)
        neg.removeValue(forKey: negKey)
        return (Payment(from: negKey, to: posKey, payment: -b), (pos, neg))
    } else {
        pos.removeValue(forKey: posKey)
        neg.updateValue(neg[negKey]! + a, forKey: negKey)
        return (Payment(from:negKey, to: posKey, payment: a), (pos, neg))
    }
}

func reconcile(_ ent: Entry) -> [Payment] {
    var result = [Payment]()
    var pos = ent.filter({$0.value > 0})
    var neg = ent.filter({$0.value < 0})
    while !pos.isEmpty && !neg.isEmpty {
        for (kp, kn) in pairs(pos: pos, neg: neg) {
            let v = pos[kp]!
            pos.removeValue(forKey: kp)
            neg.removeValue(forKey: kn)
            result.append(Payment(from: kn, to: kp, payment: v))
        }
        if let (p, (newPos, newNeg)) = randPair((pos, neg)) {
            pos = newPos
            neg = newNeg
            result.append(p)
        }
    }
    return result
}

func shortList(_ ent: Entry) -> [Payment]? {
    var paymentsList: [[Payment]] = []
    for _ in 0..<1000 {
        paymentsList.append(reconcile(ent))
    }
    return paymentsList.min(by: {$0.count < $1.count})
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

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func getSheetItURL() -> URL {
    return getDocumentsDirectory().appendingPathComponent("sheetit")
}

func writeSheet(_ sheet: Sheet) {
    let url = getSheetItURL()
    let encoder = JSONEncoder()
    do {
        let json = try encoder.encode(sheet)
        try json.write(to: url)
    } catch {
        print("Could not encode and save sheet")
    }
}

func readSheet() -> Sheet {
    let url = getSheetItURL()
    do {
        let data = try Data(contentsOf: url)
        let sheet = try JSONDecoder().decode(Sheet.self, from: data)
        return sheet
    } catch {
        return Sheet()
    }
}
