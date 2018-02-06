//
//  EntryViewController.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 11/24/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
    var currentSheet = Sheet()
    var sheetName = ""
    var selectedPeople: Set<Int> = []
    var payerIndex = -1

    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var participantTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneButton
        desc.delegate = self
        amount.delegate = self
        title = "Enter an Event"
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = true
    }
    
    @objc func doneTapped() {
        if payerIndex < 0 {
            navigationController?.popViewController(animated: true)
            return
        }
        let payer = currentSheet.people[payerIndex]
        let participants = selectedPeople.map {currentSheet.people[$0]}
        var payment = 0.0
        if let t = amount.text {
            if let p = Double(t) {
                payment = p
            }
        }
        let event = Event(eventID: UUID(), description: desc.text!, date: datePicker.date, payer: payer, participants: participants, amount: payment)
        if event.valid {
            currentSheet.events.append(event)
            writeSheet(name: sheetName, sheet: currentSheet)
        }
        navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentSheet.people.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentSheet.people[row].name
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSheet.people.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Payee", for: indexPath)
        if payerIndex == indexPath.row {
            cell.textLabel?.text = "🔵 \(currentSheet.people[indexPath.row].name)"
        } else {
            cell.textLabel?.text = "⚪️ \(currentSheet.people[indexPath.row].name)"
        }
        if selectedPeople.contains(indexPath.row) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            let isParticipant = selectedPeople.contains(indexPath.row)
            if isParticipant && indexPath.row == payerIndex {
                cell.accessoryType = .none
                selectedPeople.remove(indexPath.row)
                tableView.reloadData()
            }
            else if isParticipant {
                payerIndex = indexPath.row
                tableView.reloadData()
            }
            else if indexPath.row == payerIndex {
                payerIndex = -1
                tableView.reloadData()
            } else {
                cell.accessoryType = .checkmark
                selectedPeople.update(with: indexPath.row)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
