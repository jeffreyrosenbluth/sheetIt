//
//  PaymentViewController.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 11/24/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {
    
    @IBOutlet weak var from: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var to: UILabel!
}

class PaymentViewController: UITableViewController {
    
    var payments: [Payment]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        title = "Payments"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
        let pmt = payments![indexPath.row]
        let amt = String(format: "$%.02f", pmt.payment)
        cell.from?.text = pmt.from.name
        cell.amount?.text = amt
        cell.to?.text = pmt.to.name
        return cell
    }
}
