//
//  ViewController.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 11/22/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var currentSheet: Sheet!
    
  
// For testing, needs to be deleted. --------------------------------------------------------------
    var john: Person!
    var paul: Person!
    var george: Person!
    var ringo: Person!
    var bowling: Event!
    var skiing: Event!
//-------------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sheet-It"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addParticipantButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        let paymentsButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(paymentsTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addEventButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)

        self.toolbarItems = [addParticipantButton, space, paymentsButton, space, addEventButton]
// For testing, needs to be deleted. --------------------------------------------------------------
        john = Person(personID: UUID(), name: "John Lennon", nick: "JL")
        paul = Person(personID: UUID(), name: "Paul McCartney", nick: "PM")
        george = Person(personID: UUID(), name: "George Harrison", nick: "GH")
        ringo = Person(personID: UUID(), name: "Ringo Starr", nick: "RS")
        bowling = Event(eventID: UUID(), description: "Bowling", date: Date.init(timeIntervalSinceNow: 10), payer: john, participants: [john, paul, ringo, george], amount: 120)
        skiing = Event(eventID: UUID(), description: "Skiing at Jackson Hole", date: Date(timeIntervalSinceNow: 11), payer: ringo, participants: [george, ringo], amount: 900)
        let people = [john!, paul!, george!, ringo!]
        let events = [bowling!, skiing!]
        currentSheet = Sheet(people:people, events: events)
//-------------------------------------------------------------------------------------------------
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSheet.events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath)
        cell.textLabel?.text = currentSheet.events[indexPath.row].description
        cell.detailTextLabel?.text = String(format: "$%.02f", currentSheet.events[indexPath.row].amount)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let evc = storyboard?.instantiateViewController(withIdentifier: "Entry") as? SheetViewController {
            evc.selectedEvent = currentSheet.events[indexPath.row]
            navigationController?.pushViewController(evc, animated: true)
        }
    }
    
    @objc func paymentsTapped() {
        if let pvc = storyboard?.instantiateViewController(withIdentifier: "Payment") as? PaymentViewController {
            pvc.payments = reconcile(total(currentSheet))
            navigationController?.pushViewController(pvc, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

