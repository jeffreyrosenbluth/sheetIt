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
        title = "Sheet 💵 It"
        let textColor = UIColor(red: 64/255, green: 128/255, blue: 0, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = textColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 30)]
        navigationController?.navigationBar.prefersLargeTitles = true
        let addParticipantButton = UIBarButtonItem(title: "Add Member", style: .plain,  target: self, action: #selector(participantTapped))
        addParticipantButton.tintColor = textColor
        let settleButton = UIBarButtonItem(title: "Settle", style: .plain, target: self, action: #selector(settleTapped))
        settleButton.tintColor = textColor
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addEventButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(entryTapped))
        navigationItem.rightBarButtonItem = addEventButton
        navigationItem.leftBarButtonItem = self.editButtonItem
        toolbarItems = [addParticipantButton, space, settleButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = false
        tableView.reloadData()
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
            tableView.deleteRows(at: [indexPath], with: .automatic)
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
        func add(a: UIAlertAction) {
            if let name = participantAlertController.textFields?[0].text {
                if name != ""  {
                    currentSheet.people.append(Person(name: name, email: nil))
                    writeSheet(currentSheet)
                }
            }
        }
        participantAlertController.addTextField(configurationHandler: getName)
        nameField = participantAlertController.textFields![0]
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
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

