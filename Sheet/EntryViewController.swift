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
    var selectedPeople: Set<Int> = []

    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var participantTable: UITableView!
    @IBOutlet weak var payerPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneButton
        desc.delegate = self
        amount.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = true
    }
    
    @objc func doneTapped() {
        let payerIndex = payerPicker.selectedRow(inComponent: 0)
        let payer = currentSheet.people[payerIndex]
        let participants = selectedPeople.map {currentSheet.people[$0]}
        var payment = 0.0
        if let t = amount.text {
            if let p = Double(t) {
                payment = p
            }
        }
        let event = Event(eventID: UUID(), description: desc.text!, date: datePicker.date, payer: payer, participants: participants, amount: payment)
        currentSheet.events.append(event)
        writeSheet(currentSheet)
        navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSheet.people.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Payee", for: indexPath)
        cell.textLabel?.text = currentSheet.people[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryType == .checkmark{
                cell.accessoryType = .none
                selectedPeople.remove(indexPath.row)
            }
            else{
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
