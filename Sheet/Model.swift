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

func randPair(_ e: Entry) -> (Payment, Entry)? {
    var ent = e
    let neg = e.filter({$0.value < 0})
    let negIdx = Int(arc4random_uniform(UInt32(neg.count)))
    let negKey = Array(neg.keys)[negIdx]
    let negVal = neg[negKey]
    let pos = e.filter({$0.value > 0})
    let posIdx = Int(arc4random_uniform(UInt32(pos.count)))
    let posKey = Array(pos.keys)[posIdx]
    let posVal = pos[posKey]
    if let a = posVal {
        if let b = negVal {
            if a == abs(b) {
                ent.removeValue(forKey: negKey)
                ent.removeValue(forKey: posKey)
                return (Payment(from: negKey, to: posKey, payment: -b), ent)
            } else if a > abs(b) {
                ent.updateValue(e[posKey]! + b, forKey: posKey)
                ent.removeValue(forKey: negKey)
                return (Payment(from: negKey, to: posKey, payment: -b), ent)
            } else {
                ent.removeValue(forKey: posKey)
                ent.updateValue(e[negKey]! + a, forKey: negKey)
                return (Payment(from:negKey, to: posKey, payment: a), ent)
            }
        }
    }
    return nil
}

func pairOff(_ e: Entry) -> (Payment, Entry)? {
    var ent = e
    if let (f, a) = e.max(by: {$0.value < $1.value}) {
        if let (t, b) = e.min(by: {$0.value < $1.value}) {
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

func reconcile(_ pair: (Entry) -> (Payment, Entry)?, _ ent: Entry) -> [Payment] {
    var ent = ent
    var result = [Payment]()
    while ent.count >= 2 {
        if let (p, newEvent) = pair(ent) {
            ent = newEvent
            if p.payment > 0 {
                result.append(p)
            }
        } else {
            return [Payment(from: noOne, to: noOne, payment: 0)]
        }
    }
    return result
}

func shortList(_ ent: Entry) -> [Payment]? {
    var paymentsList: [[Payment]] = []
    for _ in 0..<1000 {
        paymentsList.append(reconcile(randPair, ent))
    }
    let small =  paymentsList.min(by: {$0.count < $1.count})
    let reg = reconcile(pairOff, ent)
    if small!.count < reg.count {
        return small
    } else {
        return reg
    }
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
