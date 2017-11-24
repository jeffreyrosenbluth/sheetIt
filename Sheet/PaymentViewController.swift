//
//  PaymentViewController.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 11/24/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import UIKit

class PaymentViewController: UITableViewController {
    
    var payments: [Payment]?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.toolbar.isHidden = true
        title = "Payments"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return payments!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath)
        let pmt = payments![indexPath.row]
        let amt = String(format: "$%.02f", pmt.payment)
        let pmtString = "\(pmt.from) pays \(amt) to \(pmt.to)"
        cell.textLabel?.text = pmtString
        return cell
    }
}
