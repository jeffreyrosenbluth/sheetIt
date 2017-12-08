//
//  Transaction.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 12/4/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

//import Foundation
import GameplayKit

struct Ledger {
    var positives: [Int]
    var negatives: [Int]
    
    var done: Bool {
        return positives.count + negatives.count == 0
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

func aStarHeuristic(_ ledger: Ledger) -> Int {
        return max(ledger.positives.count, ledger.negatives.count)
}

func inconsistentHeuristic(_ ledger: Ledger) -> Int {
    return ledger.positives.count + ledger.negatives.count
}

func neighbors(_ ledger: Ledger) -> Set<Ledger> {
    var ledgers: Set<Ledger> = []
    for (posIdx, posElem) in ledger.positives.enumerated() {
        for (negIdx, negElem) in ledger.negatives.enumerated() {
            var newPos = ledger.positives
            var newNeg = ledger.negatives
            if posElem > -negElem {
                newPos[posIdx] = posElem + negElem
                newNeg.remove(at: negIdx)
            } else if posElem < -negElem {
                newPos.remove(at: posIdx)
                newNeg[negIdx] = posElem + negElem
            } else {
                newPos.remove(at: posIdx)
                newNeg.remove(at: negIdx)
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
            return 0
        }
    }
    
    var toArray: [Ledger] {
        var a = [ledger]
        var prev = previous
        while prev != nil {
            a.append((prev?.ledger)!)
            prev = prev?.previous
        }
        a.removeLast()
        return a.reversed()
    }
}

extension Node: Equatable {
    static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.ledger == rhs.ledger
    }
}

extension Node: Comparable {
    static func <(lhs: Node, rhs: Node) -> Bool {
        return lhs.transactions + aStarHeuristic(lhs.ledger) < rhs.transactions + aStarHeuristic(rhs.ledger)
    }
}

func astarOrder(_ lhs: Node, _ rhs: Node) -> Bool {
    return lhs.transactions + aStarHeuristic(lhs.ledger) > rhs.transactions + aStarHeuristic(rhs.ledger)
}

func fastOrder(_ lhs: Node, _ rhs: Node) -> Bool {
    return lhs.transactions + inconsistentHeuristic(lhs.ledger) > rhs.transactions + inconsistentHeuristic(rhs.ledger)
}

func solve(comp: @escaping (Node, Node) -> Bool, ledger: Ledger) -> Node {
    var frontier = PriorityQueue<Node>(order: comp)
    var ledgers = Set([ledger])
    var minNode = Node(ledger)
    frontier.push(Node(ledger))
    repeat {
        if let node = frontier.pop() {
            if node.ledger.done {return node}
            for l in neighbors(node.ledger) {
                if !(ledgers.contains(l)) {
                    frontier.push(Node(l, node.transactions + 1, node))
                    ledgers.update(with: l)
                    if l.positives.count + l.negatives.count < minNode.ledger.positives.count + minNode.ledger.negatives.count {
                        minNode = Node(l, 0, node)
                    }
                } 
            }
        }
    } while true
}
