//
//  ViewController.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 11/22/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UITextFieldDelegate, SheetsDelegate {
    
    
    
    var currentSheet: Sheet!
    var sheetName: String!
    var nameField = UITextField()
    var nickField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EntryCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Add")

        title = "Sheet 💵 It"
        let textColor = UIColor(red: 64/255, green: 128/255, blue: 0, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = textColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 30)]
        navigationController?.navigationBar.prefersLargeTitles = true
        let sheetsButton = UIBarButtonItem(title: "Sheets", style: .plain,  target: self, action: #selector(sheetsTapped))
        sheetsButton.tintColor = textColor
        let settleButton = UIBarButtonItem(title: "Settle", style: .plain, target: self, action: #selector(settleTapped))
        settleButton.tintColor = textColor
        let addMemberButton = UIBarButtonItem(title: "Add Member", style: .plain, target: self, action: #selector(participantTapped))
        addMemberButton.tintColor = textColor
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [addMemberButton]
        navigationItem.leftBarButtonItem = self.editButtonItem
        navigationController?.setToolbarHidden(false, animated: true)
        toolbarItems = [sheetsButton, space, settleButton]
        let sheetNames = UserDefaults.standard.object(forKey:"SavedSheets") as? [String] ?? [String]()
        let sheetIndex = UserDefaults.standard.integer(forKey: "Index")
        if sheetNames == [] {
            currentSheet = Sheet()
        } else {
            sheetName = sheetNames[sheetIndex]
            currentSheet = readSheet(sheetName)
            title = sheetName
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = false
        tableView.reloadData()
    }
    
    func dataChanged(_ sheet: String) {
        sheetName = sheet
        title = sheet
        currentSheet = readSheet(sheet)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSheet.events.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == currentSheet.events.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Add", for: indexPath)
            let button = UIButton(type: .contactAdd)
            cell.addSubview(button)
            button.addTarget(self, action: #selector(entryTapped), for: UIControlEvents.touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            button.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath)
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.textLabel?.text = currentSheet.events[indexPath.row].description
        cell.detailTextLabel?.text = String(format: "$%.02f", currentSheet.events[indexPath.row].amount)
        return cell
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let evc = EventViewController()
        let event = currentSheet.events[indexPath.row]
        evc.sheetName = sheetName
        evc.descriptionView.text = event.description
        evc.amountView.text = String(format: "%.02f", event.amount)
        evc.dateView.date = event.date
        evc.currentEvent = event
        evc.currentSheet = currentSheet
        navigationController?.pushViewController(evc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            currentSheet.events.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            writeSheet(name: sheetName, sheet: currentSheet)
        }
    }
    
    @objc func settleTapped() {
        let pvc = PaymentViewController()
        let entry = total(currentSheet)
        if entry.count > 15 {
            pvc.payments = shortList(entry)?.sorted(by: {$0.payment >= $1.payment})
        } else {
            let l = toLedger(entry)
            pvc.payments = reconcileLedgerOpt(l).sorted(by: {$0.payment >= $1.payment})
        }
        navigationController?.pushViewController(pvc, animated: true)
    }
    
    @objc func entryTapped() {
        let evc = EventViewController()
        evc.currentSheet = currentSheet
        evc.sheetName = sheetName
        navigationController?.pushViewController(evc, animated: true)
    }
    
    @objc func sheetsTapped() {
        let svc = SheetsViewController()
        svc.delegate = self
        navigationController?.pushViewController(svc, animated: true)
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
                    writeSheet(name: sheetName, sheet: currentSheet)
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

