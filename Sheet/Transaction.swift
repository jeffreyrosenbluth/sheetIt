
//  Transaction.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 12/4/17.
//  Copyright © 2017 Applause Code. All rights reserved.

struct Ledger<T: Hashable> {
    var positives: [T: Int]
    var negatives: [T: Int]
    
    var count: Int {
        return positives.count + negatives.count
    }
    
    var done: Bool {
        return count == 0
    }
}

extension Ledger: Equatable {
    static func ==(lhs: Ledger, rhs: Ledger) -> Bool {
        return lhs.positives == rhs.positives &&
               lhs.negatives == rhs.negatives
    }
}

extension Ledger: Hashable {
    var hashValue: Int {
        let s = "\(positives)\(negatives)"
        return s.hashValue
    }
}

func powerSet<T>(_ set: [T]) -> [[T]] {
    var result: [[T]] = [[]]
    for x in set {
        for r in result {
            var t = r
            t = t + [x]
            result.append(t)
        }
    }
    return result
}

func indexedPowerSet<T>(_ ps: [[T]], _ n: Int) -> [[[T]]] {
    var ips: [[[T]]] = Array(repeating: [], count: n)
    for x in ps {
        if x.count < 1 { continue }
        let xs = ips[x.count - 1]
        let ys = xs + [x]
        ips[x.count - 1] = ys
    }
    return ips
}

func summands(_ n: Int) -> [(Int, Int)] {
    var result:[(Int, Int)] = []
    for i in 1..<n {
        result.append((i, n - i))
    }
    return result
}

// Calculate the optimal set of transactions from a Ledger.
func trxs<T>(_ ledger: Ledger<T>) -> [([T], [T])] {
    var result: [([T], [T])] = []
    // Start by creating two arrays, one of the keys of the positive entries
    // and one of the keys of the negative entryies.
    let pos = Array(ledger.positives.keys)
    let neg = Array(ledger.negatives.keys)
    // Create indexed power sets for each, i.e. divide the power set amongst buckets
    // according to the count of each set. Such that the count becomes the index in an array.
    let pSet = indexedPowerSet(powerSet(pos), pos.count)
    let nSet = indexedPowerSet(powerSet(neg), neg.count)
    let n = pos.count + neg.count - 2
    // Keep track of the keys of settled transactions.
    var used = Set<T>()
    // If n < 2 then there are at most 3 keys and the pos keys are simply paired with the neg keys.
    if n < 2 { return [(pos, neg)] }
    for i in 2...n {
        let idxs = summands(i)
        for (j, k) in idxs {
            if j > pSet.count - 1 || k > nSet.count - 1 { continue }
            let xs = pSet[j-1]
            let ys = nSet[k-1]
            for x in xs {
                for y in ys {
                    var xSum = 0
                    var ySum = 0
                    for xKey in x {
                        xSum += ledger.positives[xKey]!
                    }
                    for yKey in y {
                        ySum += ledger.negatives[yKey]!
                    }
                    if xSum == ySum && used.isDisjoint(with: Set(x).union(Set(y))) {
                        used = used.union(Set(x)).union(Set(y))
                        result = result + [(x, y)]
                    }
                }
            }
        }
    }
    let pRemaining = Array(Set(pos).subtracting(used))
    let nRemaining = Array(Set(neg).subtracting(used))
    return result + [(pRemaining, nRemaining)]
}

func trsxToLedger<T>(_ txs: [([T], [T])], _ ledger: Ledger<T>) -> [Ledger<T>] {
    var ledgers: [Ledger<T>] = []
    for tx in txs {
        var pos: [T: Int] = [:]
        var neg: [T: Int] = [:]
        for t in tx.0 {
            pos.updateValue(ledger.positives[t]!, forKey: t)
        }
        for t in tx.1 {
            neg.updateValue(ledger.negatives[t]!, forKey: t)
        }
        ledgers.append(Ledger<T>(positives: pos, negatives: neg))
    }
    return ledgers
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

func pairOff(_ ledger: Ledger<Person>) -> (Payment, Ledger<Person>)! {
    var pos = ledger.positives
    var neg = ledger.negatives
    if let (f, a) = maxValue(pos) {
        if let (t, b) = maxValue(neg) {
            if a == b {
                neg.removeValue(forKey: t)
                pos.removeValue(forKey: f)
                return (Payment(from: t, to: f, payment: Double(a)/100), Ledger<Person>(positives: pos, negatives: neg))
            }
            if a > b {
                pos.updateValue(pos[f]! - b, forKey: f)
                neg.removeValue(forKey: t)
                return (Payment(from: t, to: f, payment: Double(b)/100), Ledger<Person>(positives: pos, negatives: neg))
            } else {
                pos.removeValue(forKey: f)
                neg.updateValue(neg[t]! - a, forKey: t)
                return (Payment(from: t, to: f, payment: Double(a)/100), Ledger<Person>(positives: pos, negatives: neg))
            }
        }
    }
    return nil
}

func reconcileLedger(_ ledger: Ledger<Person>) -> [Payment] {
    var ledger = ledger
    var result = [Payment]()
    while ledger.count >= 2 {
        if let (p, newLedger) = pairOff(ledger) {
            ledger = newLedger
            result.append(p)
        } else {
            return [Payment(from: noOne, to: noOne, payment: 0)]
        }
    }
    return result
}

func reconcileLedgerOpt(_ ledger: Ledger<Person>) -> [Payment] {
    var payments: [Payment] = []
    let txs = trxs(ledger)
    let ledgers = trsxToLedger(txs, ledger)
    for l in ledgers {
        payments.append(contentsOf: reconcileLedger(l))
    }
    return payments
}
