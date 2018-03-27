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
        
        let marginGuide = contentView.layoutMarginsGuide
        let ultraLight = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.ultraLight)
        let semiBold = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        
        contentView.addSubview(from)
        from.translatesAutoresizingMaskIntoConstraints = false
        from.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        from.topAnchor.constraint(equalTo: marginGuide.topAnchor, constant: 10).isActive = true
        from.font = semiBold
        
        let fromLabel = UILabel()
        contentView.addSubview(fromLabel)
        fromLabel.translatesAutoresizingMaskIntoConstraints = false
        fromLabel.topAnchor.constraint(equalTo: from.bottomAnchor, constant: 5).isActive = true
        fromLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        fromLabel.font = ultraLight
        fromLabel.text = "pays →"
        
        contentView.addSubview(amount)
        amount.translatesAutoresizingMaskIntoConstraints = false
        amount.centerXAnchor.constraint(equalTo: marginGuide.centerXAnchor).isActive = true
        amount.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        amount.font = semiBold
        
        let toLabel = UILabel()
        contentView.addSubview(toLabel)
        toLabel.translatesAutoresizingMaskIntoConstraints = false
        toLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        toLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor, constant: 10).isActive = true
        toLabel.font = ultraLight
        toLabel.text = "→ to"
        
        contentView.addSubview(to)
        to.translatesAutoresizingMaskIntoConstraints = false
        to.topAnchor.constraint(equalTo: toLabel.bottomAnchor, constant: 5).isActive = true
        to.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        to.font = semiBold
        
        let greenColor = UIColor(red: 64/255, green: 128/255, blue: 0, alpha: 1)
        let redColor = UIColor(red: 166/255, green: 0, blue: 0, alpha: 1)
        to.textColor = greenColor
        from.textColor = redColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PaymentViewController: UITableViewController {
    
    var payments: [Payment]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        title = "Payments"
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
