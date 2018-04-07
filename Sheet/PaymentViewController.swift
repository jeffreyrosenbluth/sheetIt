//
//  PaymentViewController.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 11/24/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {
    
    let from = UILabel()
    let amount = UILabel()
    let to = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let ultraLight = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.ultraLight)
        let semiBold = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        
        contentView.addSubview(from, constraints: [
            equal(\.leadingAnchor, \.layoutMarginsGuide.leadingAnchor),
            equal(\.topAnchor, \.layoutMarginsGuide.topAnchor, 10)
        ])
        from.font = semiBold
        
        let fromLabel = UILabel()
        contentView.addSubview(fromLabel, constraints: [
            equal(\.leadingAnchor, \.layoutMarginsGuide.leadingAnchor)
        ])
        fromLabel.topAnchor.attach(from.bottomAnchor, 5)
        fromLabel.font = ultraLight
        fromLabel.text = "pays →"

        contentView.addSubview(amount, constraints: [
            equal(\.centerXAnchor, \.layoutMarginsGuide.centerXAnchor),
            equal(\.centerYAnchor, \.layoutMarginsGuide.centerYAnchor)
        ])
        amount.font = semiBold
        
        let toLabel = UILabel()
        contentView.addSubview(toLabel, constraints: [
            equal(\.trailingAnchor, \.layoutMarginsGuide.trailingAnchor),
            equal(\.topAnchor, \.layoutMarginsGuide.topAnchor, 10)
            ])
        toLabel.font = ultraLight
        toLabel.text = "→ to"
        
        contentView.addSubview(to, constraints: [
            equal(\.trailingAnchor, \.layoutMarginsGuide.trailingAnchor)
        ])
        to.topAnchor.attach(toLabel.bottomAnchor, 5)
        to.font = semiBold
        
        to.textColor = UIColor(named: "dollarGreen")
        from.textColor = UIColor(named: "brick")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PaymentViewController: UITableViewController {
    
    var payments: [Payment]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settlement"
        tableView.register(PaymentCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 75
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = true
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PaymentCell
        let pmt = payments![indexPath.row]
        let amt = String(format: "$%.02f", pmt.payment)
        cell.from.text = pmt.from.name
        cell.amount.text = amt
        cell.to.text = pmt.to.name
        return cell
    }
}
