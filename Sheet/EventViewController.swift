//
//  EventViewController.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 3/25/18.
//  Copyright © 2018 Applause Code. All rights reserved.
//

import UIKit

class PersonCell: UICollectionViewCell {
    var text = UILabel()
    var check = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        text.backgroundColor = .white
        text.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(text)
        text.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        check.backgroundColor = .white
        check.translatesAutoresizingMaskIntoConstraints = false
        check.text = "✓"
        check.font = UIFont.boldSystemFont(ofSize: 17)
        contentView.addSubview(check)
        check.leadingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        check.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EventViewController: UIViewController {
   
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        let doneButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneButton
        title = "Enter an Event"
        
        descriptionView.delegate = self
        amountView.delegate = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(PersonCell.self, forCellWithReuseIdentifier: "Person")
        cv.backgroundColor = .white
        cv.translatesAutoresizingMaskIntoConstraints = false
       
        view.backgroundColor = .white
        view.addSubview(descriptionView)
        view.addSubview(amountView)
        view.addSubview(dateView)
        
        setupLayout()
        
        view.addSubview(cv)
        cv.topAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 12).isActive = true
        cv.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        cv.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        cv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
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
        
        amountView.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 10).isActive = true
        amountView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        amountView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        dateView.topAnchor.constraint(equalTo: amountView.bottomAnchor, constant: 12).isActive = true
        dateView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        dateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension EventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = view.frame.width
        return CGSize(width: (w-80) / 2, height: 35);
    }
}

extension EventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentSheet.people.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as! PersonCell
        if payerIndex == indexPath.row {
            cell.text.text = "🔵 \(currentSheet.people[indexPath.row].name)"
        } else {
            cell.text.text = "⚪️ \(currentSheet.people[indexPath.row].name)"
        }
        if selectedPeople.contains(indexPath.row) {
            cell.check.textColor = .blue
        } else {
            cell.check.textColor = .white
        }
        cell.backgroundColor = .white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let cell = collectionView.cellForItem(at: indexPath as IndexPath) as? PersonCell {
            let isParticipant = selectedPeople.contains(indexPath.row)
            if isParticipant && indexPath.row == payerIndex {
                cell.check.textColor = .white
                selectedPeople.remove(indexPath.row)
                collectionView.reloadData()
            }
            else if isParticipant {
                payerIndex = indexPath.row
                collectionView.reloadData()
            }
            else if indexPath.row == payerIndex {
                payerIndex = -1
                collectionView.reloadData()
            } else {
                cell.check.textColor = .blue
                selectedPeople.update(with: indexPath.row)
            }
        }
    }
}

extension EventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
