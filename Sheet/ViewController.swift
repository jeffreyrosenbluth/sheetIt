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
// For testing, needs to be deleted. --------------------------------------------------------------
        john = Person(personID: UUID(), name: "John Lennon", nick: "JL")
        paul = Person(personID: UUID(), name: "Paul McCartney", nick: "PM")
        george = Person(personID: UUID(), name: "George Harrison", nick: "GH")
        ringo = Person(personID: UUID(), name: "Ringo Starr", nick: "RS")
        bowling = Event(eventID: UUID(), description: "Bowling", date: Date.init(timeIntervalSinceNow: 10), payer: john, participants: [john, paul, ringo, george], amount: 120)
        skiing = Event(eventID: UUID(), description: "Skiing at Jackson Hole", date: Date(timeIntervalSinceNow: 11), payer: ringo, participants: [george, ringo], amount: 900)
        currentSheet = [bowling, skiing]
//-------------------------------------------------------------------------------------------------
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSheet.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath)
        cell.textLabel?.text = currentSheet[indexPath.row].description
        cell.detailTextLabel?.text = String(format: "$%.02f", currentSheet[indexPath.row].amount)
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

