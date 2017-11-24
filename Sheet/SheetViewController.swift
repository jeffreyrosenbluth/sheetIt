//
//  SheetViewController.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 11/23/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import UIKit

class SheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    var selectedEvent: Event?
    
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var payer: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        title = "Event"
        desc.text = selectedEvent?.description
        payer.text = selectedEvent?.payer.name
        amount.text = String(format: "$%.02f", selectedEvent!.amount)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        date.text = dateFormatter.string(from:selectedEvent!.date)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (selectedEvent?.participants.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Participant", for: indexPath)
            cell.textLabel?.text = selectedEvent?.participants[indexPath.row].name
            return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
