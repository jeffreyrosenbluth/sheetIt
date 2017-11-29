//
//  ViewController.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 11/22/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UITextFieldDelegate {
    
    var currentSheet = readSheet()
    var nameField = UITextField()
    var nickField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sheet-It"
        navigationController?.navigationBar.prefersLargeTitles = true
        let addParticipantButton = UIBarButtonItem(title: "Add Member", style: .plain,  target: self, action: #selector(participantTapped))
        let settleButton = UIBarButtonItem(title: "Settle", style: .plain, target: self, action: #selector(settleTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addEventButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(entryTapped))
        navigationItem.rightBarButtonItem = addEventButton
        navigationItem.leftBarButtonItem = self.editButtonItem
        self.toolbarItems = [addParticipantButton, space, settleButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = false
        self.tableView.reloadData()
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
        if let evc = storyboard?.instantiateViewController(withIdentifier: "Sheet") as? SheetViewController {
            evc.selectedEvent = currentSheet.events[indexPath.row]
            navigationController?.pushViewController(evc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            currentSheet.events.remove(at: indexPath.row)
            tableView.reloadData()
            writeSheet(currentSheet)
        }
    }
    
    @objc func settleTapped() {
        if let pvc = storyboard?.instantiateViewController(withIdentifier: "Payment") as? PaymentViewController {
            pvc.payments = reconcile(total(currentSheet))
            navigationController?.pushViewController(pvc, animated: true)
        }
    }
    
    @objc func entryTapped() {
        if let evc = storyboard?.instantiateViewController(withIdentifier: "Entry") as? EntryViewController {
            evc.currentSheet = currentSheet
            navigationController?.pushViewController(evc, animated: true)
            }
    }
    
    @objc func participantTapped() {
        let participantAlertController = UIAlertController(title: "New Participant", message: nil, preferredStyle: .alert)
        
        func getName(t: UITextField) {
            t.placeholder = "Name"
            t.clearButtonMode = .always
            t.delegate = self
        }
        func getNick(t: UITextField) {
            t.placeholder = "Initials"
            t.clearButtonMode = .always
        }
        func add(a: UIAlertAction) {
            if let name = participantAlertController.textFields?[0].text {
                if let nick = participantAlertController.textFields?[1].text {
                    if name != "" && nick != "" {
                        currentSheet.people.append(Person(personID: UUID(), name: name, nick: nick))
                        writeSheet(currentSheet)
                    }
                }
            }
        }
        participantAlertController.addTextField(configurationHandler: getName)
        participantAlertController.addTextField(configurationHandler: getNick)
        nameField = participantAlertController.textFields![0]
        nickField = participantAlertController.textFields![1]
        participantAlertController.addAction(UIAlertAction(title: "Add", style: .default, handler: add))
        participantAlertController.addAction((UIAlertAction(title: "Cancel", style: .cancel, handler: nil)))
        present(participantAlertController, animated: true)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField === nameField {
            if currentSheet.people.map({$0.name}).contains(nameField.text!) {
                return false
            }
        }
        if textField === nickField {
            if currentSheet.people.map({$0.nick}).contains(nickField.text!) {
                return false
            }
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

