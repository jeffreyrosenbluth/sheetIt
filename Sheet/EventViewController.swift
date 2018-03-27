//
//  EventViewController.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 3/25/18.
//  Copyright © 2018 Applause Code. All rights reserved.
//

import UIKit

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    var currentEvent: Event?
    var currentSheet = Sheet()
    var sheetName = ""
    var selectedPeople: Set<Int> = []
    var payerIndex = -1
    
    let descriptionView: UITextField = {
        let descriptionView =  UITextField()
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.font = UIFont.systemFont(ofSize: 17)
        descriptionView.placeholder = "Event"
        descriptionView.borderStyle = .roundedRect
        return descriptionView
    }()

    let amountView: UITextField = {
        let amountView =  UITextField()
        amountView.translatesAutoresizingMaskIntoConstraints = false
        amountView.font = UIFont.systemFont(ofSize: 17)
        amountView.placeholder = "Amount"
        amountView.borderStyle = .roundedRect
        return amountView
    }()
    
    let dateView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        return picker
    }()
    
    let participantView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        let doneButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneButton
        title = "Enter an Event"
        
        descriptionView.delegate = self
        amountView.delegate = self
        participantView.delegate = self
        participantView.dataSource = self
        
        view.backgroundColor = .white
        view.addSubview(descriptionView)
        view.addSubview(amountView)
        view.addSubview(dateView)
        view.addSubview(participantView)
        setupLayout()
        
        if let event = currentEvent {
            let (payer, players) = participants(event: event, sheet: currentSheet)
            payerIndex = payer
            selectedPeople = players
        }
    }
    
    private func setupLayout() {
        descriptionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        descriptionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        descriptionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        amountView.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 6).isActive = true
        amountView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        amountView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        dateView.topAnchor.constraint(equalTo: amountView.bottomAnchor, constant: 6).isActive = true
        dateView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        dateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        participantView.topAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 6).isActive = true
        participantView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        participantView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        participantView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSheet.people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
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
        if let t = amountView.text {
            if let p = Double(t) {
                payment = p
            }
        }
        let event = Event(eventID: UUID(), description: descriptionView.text!, date: dateView.date, payer: payer, participants: participants, amount: payment)
        if event.valid {
            if let cs = currentEvent {
                currentSheet.deleteEntry(id: cs.eventID)
            }
            currentSheet.events.append(event)
            currentSheet.events.sort(by: {$0.date < $1.date})
            writeSheet(name: sheetName, sheet: currentSheet)
        }
        navigationController?.popViewController(animated: true)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
        
}
