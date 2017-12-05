//
//  Transaction.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 12/4/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

//import Foundation

struct Ledger {
    var positives: [Int]
    var negatives: [Int]
    
    var posCount: Int {
        return positives.filter({$0 > 0}).count
    }
    
    var negCount: Int {
        return negatives.filter({$0 < 0}).count
    }
    
    var done: Bool {
        return negCount + posCount == 0
    }
}

extension Ledger: Equatable {
    static func ==(lhs: Ledger, rhs: Ledger) -> Bool {
        return lhs.positives.reduce(0, +) == rhs.positives.reduce(0, +) &&
               lhs.negatives.reduce(0, +) == rhs.negatives.reduce(0, +)
    }
}

extension Ledger: Hashable {
    var hashValue: Int {
        let s = "\(positives.reduce(0, +))\(negatives.reduce(0, +))"
        return s.hashValue
    }
}

func heuristic(_ ledger: Ledger) -> Int {
    return max(ledger.posCount, ledger.negCount)
}

func neighbors(_ ledger: Ledger) -> Set<Ledger> {
    var ledgers: Set<Ledger> = []
    for (posIdx, posElem) in ledger.positives.enumerated() {
        for (negIdx, negElem) in ledger.negatives.enumerated() {
            var newPos = ledger.positives
            var newNeg = ledger.negatives
            if posElem > -negElem {
                newPos[posIdx] = posElem + negElem
                newNeg[negIdx] = 0
            } else if posElem < -negElem {
                newPos[posIdx] = 0
                newNeg[negIdx] = posElem + negElem
            } else {
                newPos[posIdx] = 0
                newNeg[negIdx] = 0
            }
            ledgers.insert(Ledger(positives: newPos, negatives: newNeg))
        }
    }
    return ledgers
}

class Node {
    let ledger: Ledger
    let transactions: Int
    let previous: Node?
    
    init(_ ledger: Ledger) {
        self.ledger = ledger
        self.transactions = 0
        self.previous = nil
    }
    
    init(_ ledger: Ledger, _ transactions: Int, _ previous: Node?) {
        self.ledger = ledger
        self.transactions = transactions
        self.previous = previous
    }
    
    var count: Int {
        if let p = previous {
            return 1 + p.count
        } else {
            return 1
        }
    }
    
    var toArray: [Ledger] {
        var a = [ledger]
        var prev = previous
        while prev != nil {
            a.append((prev?.ledger)!)
            prev = prev?.previous
        }
        return a
    }
}

extension Node: Equatable {
    static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.ledger == rhs.ledger
    }
}

extension Node: Comparable {
    static func <(lhs: Node, rhs: Node) -> Bool {
        return lhs.transactions + heuristic(lhs.ledger) < rhs.transactions + heuristic(rhs.ledger)
    }
}

func solve(ledger: Ledger) -> Node {
    var frontier = PriorityQueue<Node>(ascending: true)
    frontier.push(Node(ledger))
    repeat {
        if let node = frontier.pop() {
            if node.ledger.done {return node}
            for l in neighbors(node.ledger) {
                if node.previous == nil || !(l == node.previous?.ledger) {
                    frontier.push(Node(l, node.transactions + 1, node))
                }
            }
        }
    } while true
}
