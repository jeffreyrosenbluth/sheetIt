//
//  DebtViewController.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 3/31/18.
//  Copyright © 2018 Applause Code. All rights reserved.
//

import UIKit

final class DebtCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class DebtViewController: UITableViewController {
    var entry: Entry = [:]
    var debts: [(String, Double)] {
        var ps: [(String, Double)] = []
        for (k,v) in entry {
            ps.append((k.name,v))
        }
        return ps
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DebtCell.self, forCellReuseIdentifier: "Cell")
        title = "Debts"
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DebtCell
        let amount = debts[indexPath.row].1
        cell.textLabel?.text = debts[indexPath.row].0
        if amount < 0 {
            cell.detailTextLabel?.text = String(format: "-$%.02f", -amount)
            cell.detailTextLabel?.textColor = UIColor(named: "brick")
        } else {
            cell.detailTextLabel?.text = String(format: "$%.02f", amount)
            cell.detailTextLabel?.textColor = UIColor(named: "dollarGreen")
        }
        return cell
    }
}
