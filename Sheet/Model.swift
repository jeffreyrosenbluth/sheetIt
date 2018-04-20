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
        var e: Entry = participants.reduce(into: [:]) { result, element in
            return result[element] = owe
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
    
    func deleteEntry(id: UUID) {
        events = events.filter({$0.eventID != id})
    }
}

func participants(event: Event, sheet: Sheet) -> (Int, Set<Int>) {
    let people = sheet.people
    let players = event.participants
    let payer = event.payer
    let payerIndex = people.index(of: payer) ?? -1
    let playerIndices = players.map({people.index(of: $0) ?? -1})
    return (payerIndex, Set(playerIndices))
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

func pairs<K,V: Numeric>(pos: [K:V], neg: [K:V]) -> [(K, K)] {
    var result: [(K,K)] = []
    for (k, v) in pos {
        if let r = neg.first(where: {$0.value == 0 - v}) {
            result.append((k, r.0))
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

func getSheetItURL(_ name: String) -> URL {
    return getDocumentsDirectory().appendingPathComponent(name)
}

func writeSheet(name: String, sheet: Sheet) {
    let url = getSheetItURL(name)
    let encoder = JSONEncoder()
    do {
        let json = try encoder.encode(sheet)
        try json.write(to: url)
    } catch let error {
        print(error)
    }
}

func readSheet(_ name: String) -> Sheet {
    let url = getSheetItURL(name)
    do {
        let data = try Data(contentsOf: url)
        let sheet = try JSONDecoder().decode(Sheet.self, from: data)
        return sheet
    } catch {
        return Sheet()
    }
}

// Settlement Algorithm

func combinations<T>(_ xs: [T], _ k: Int) -> [[T]] {
    guard xs.count >= k else { return [] }
    guard xs.count > 0 && k > 0 else { return [[]] }
    if k == 1 {
        return xs.map {[$0]}
    }
    var c = [[T]]()
    for (idx, x) in xs.enumerated() {
        var xs1 = xs
        xs1.removeFirst(idx + 1)
        c += combinations(xs1, k - 1).map {[x] + $0}
    }
    return c
}

typealias Dict<T> = [Int : [[T]]]

func tabulate(_ entry: Entry, _ m: Int) -> (posDict: Dict<Person>, negDict: Dict<Person>) {
    var pDict: Dict<Person> = [:]
    var nDict: Dict<Person> = [:]
    let keys = Array(entry.keys)
    for i in 1...m {
        for ys in combinations(keys, i) {
            let sum = ys.reduce(0, {r, e in
                return r + Int(entry[e]! * 100)
            })
            if sum > 0 {
                var val = pDict[sum] ?? []
                val.append(ys)
                pDict.updateValue(val, forKey: sum)
            } else if sum < 0 {
                var val = nDict[sum] ?? []
                val.append(ys)
                nDict.updateValue(val, forKey: sum)
            }
        }
    }
    return (pDict, nDict)
}

func matches(posDict: Dict<Person>, negDict: Dict<Person>) -> [[Person]] {
    var people : [[Person]] = []
    for (v, p) in posDict {
        guard var qs = negDict[-v] else { continue }
        var ps = p
        while !ps.isEmpty && !qs.isEmpty {
            if !hasOverlap(ps[0], qs[0]) {
                let rs = ps[0] + qs[0]
                people.append(rs)
            }
            ps.removeFirst()
            qs.removeFirst()
        }
    }
    return people.sorted(){$0.count <= $1.count}
}

func hasOverlap<T: Equatable>(_ xs: [T], _ ys: [T]) -> Bool {
    for x in xs {
        if ys.contains(x) {
            return true
        }
    }
    return false
}

func validMatches(_ people: [[Person]], _ n: Int) -> [[Person]] {
    var used: [Person] = []
    var result: [[Person]] = []
    for ps in people {
        if !hasOverlap(used, ps) {
            used.append(contentsOf: ps)
            result.append(ps)
            if used.count == n { return result}
        }
    }
    return result
}

func pair(_ entry: Entry) -> (Payment, Entry) {
    var ent = entry
    var pos = entry.filter(){ $0.value > 0 }
    var neg = entry.filter(){ $0.value < 0 }
    let (f, a) = maxValue(pos)!
    let (t, temp) = minValue(neg)!
    let b = -temp
    if a == b {
        ent.removeValue(forKey: t)
        ent.removeValue(forKey: f)
        return (Payment(from: t, to: f, payment: a), ent)
    }
    if a > b {
        ent.updateValue(pos[f]! - b, forKey: f)
        ent.removeValue(forKey: t)
        return (Payment(from: t, to: f, payment: b), ent)
    } else {
        ent.removeValue(forKey: f)
        ent.updateValue(neg[t]! + a, forKey: t)
        return (Payment(from: t, to: f, payment: a), ent)
    }
}

func reconcileNaive(_ entry: Entry) -> [Payment] {
    var ent = entry
    var result = [Payment]()
    while ent.count >= 2 {
        let (p, newEnt) = pair(ent)
        ent = newEnt
        result.append(p)
    }
    return result
}

func fromKeys<K, V>(_ dict: [K : V], _ keys: [K]) -> [K : V] {
    return dict.filter(){keys.contains($0.key)}
}

func settle(_ entry: Entry) -> [Payment] {
    let table = tabulate(entry, 6)
    let groups = matches(posDict: table.posDict, negDict: table.negDict)
    let validGroups = validMatches(groups, entry.count)
    let validDicts = validGroups.map(){ fromKeys(entry, $0) }
    let validPayments = Array(validDicts.map(){ reconcileNaive($0) }.joined())
    let remaining = entry.filter(){ !validGroups.joined().contains($0.key) }
    let remainingPayments = reconcileNaive(remaining)
    return validPayments + remainingPayments
}
