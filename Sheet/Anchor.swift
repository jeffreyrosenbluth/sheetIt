//
//  Anchor.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 4/2/18.
//  Copyright © 2018 Applause Code. All rights reserved.
//

import UIKit

typealias Constraint = (_ child: UIView, _ parent: UIView) -> NSLayoutConstraint

extension UIView {
    func addSubview(_ other: UIView, constraints: [Constraint]) {
        addSubview(other)
        other.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints.map { c in
            c(other, self)
        })
    }
}

@objc extension NSLayoutAnchor {
    func attach(_ c: NSLayoutAnchor<AnchorType>, _ constant: CGFloat) {
        self.constraint(equalTo: c , constant: constant).isActive = true
    }
}

func equal<L, Axis>(_ to: KeyPath<UIView, L>) -> Constraint
    where L: NSLayoutAnchor<Axis> {
    return { child, parent in
        child[keyPath: to].constraint(equalTo: parent[keyPath: to])
    }
}

func equal<L>(_ keyPath: KeyPath<UIView, L>, to constant: CGFloat) -> Constraint
    where L: NSLayoutDimension {
    return { child, parent in
        child[keyPath: keyPath].constraint(equalToConstant: constant)
    }
}

func equal<L, Axis>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>) -> Constraint
    where L: NSLayoutAnchor<Axis> {
    return { child, parent in
        child[keyPath: from].constraint(equalTo: parent[keyPath: to])
    }
}

func equal<L, Axis>(_ from: KeyPath<UIView, L>, _ to: KeyPath<UIView, L>, _ constant: CGFloat) -> Constraint
    where L: NSLayoutAnchor<Axis> {
    return { child, parent in
        child[keyPath: from].constraint(equalTo: parent[keyPath: to], constant: constant)
    }
}

func equal<L, Axis>(_ to: KeyPath<UIView, L>, _ constant: CGFloat) -> Constraint
    where L: NSLayoutAnchor<Axis> {
    return {child, parent in
        child[keyPath: to].constraint(equalTo: parent[keyPath: to], constant: constant)
    }
}

