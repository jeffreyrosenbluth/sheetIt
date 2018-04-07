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
        contentView.addSubview(text, constraints: [
            equal(\.topAnchor),
            equal(\.leadingAnchor)
        ])
        
        check.backgroundColor = .white
        check.text = "✓"
        check.font = UIFont.boldSystemFont(ofSize: 17)
        contentView.addSubview(check, constraints: [
            equal(\.topAnchor)
        ])
        check.leadingAnchor.attach(trailingAnchor, -20)
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
        descriptionView.font = UIFont.systemFont(ofSize: 17)
        descriptionView.placeholder = "Event"
        descriptionView.borderStyle = .roundedRect
        return descriptionView
    }()

    let amountView: UITextField = {
        let amountView =  UITextField()
        amountView.font = UIFont.systemFont(ofSize: 17)
        amountView.placeholder = "Amount"
        amountView.borderStyle = .roundedRect
        return amountView
    }()
    
    let dateView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()
    
    let peopleView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PersonCell.self, forCellWithReuseIdentifier: "Person")
        cv.backgroundColor = .white
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        let doneButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneButton
        title = "Enter an Event"
        
        descriptionView.delegate = self
        amountView.delegate = self
        peopleView.delegate = self
        peopleView.dataSource = self
       
        view.backgroundColor = .white
        
        view.addSubview(descriptionView, constraints: [
            equal(\.leadingAnchor, \.safeAreaLayoutGuide.leadingAnchor, 20),
            equal(\.topAnchor, \.safeAreaLayoutGuide.topAnchor, 20),
            equal(\.trailingAnchor, \.safeAreaLayoutGuide.trailingAnchor, -20)
        ])
        
        view.addSubview(amountView, constraints: [
            equal(\.leadingAnchor, \.safeAreaLayoutGuide.leadingAnchor, 20),
            equal(\.trailingAnchor, \.safeAreaLayoutGuide.trailingAnchor, -20)
            ])
        amountView.topAnchor.attach(descriptionView.bottomAnchor, 10)
        
        view.addSubview(dateView, constraints: [
            equal(\.leadingAnchor, \.safeAreaLayoutGuide.leadingAnchor, 20),
            equal(\.trailingAnchor, \.safeAreaLayoutGuide.trailingAnchor, -20)
            ])
        dateView.topAnchor.attach(amountView.bottomAnchor, 12)
        
        view.addSubview(peopleView, constraints: [
            equal(\.leadingAnchor, \.safeAreaLayoutGuide.leadingAnchor, 20),
            equal(\.trailingAnchor, \.safeAreaLayoutGuide.trailingAnchor, -20),
            equal(\.bottomAnchor, \.safeAreaLayoutGuide.bottomAnchor)
            ])
        peopleView.topAnchor.attach(dateView.bottomAnchor, 12)
        
        if let event = currentEvent {
            let (payer, players) = participants(event: event, sheet: currentSheet)
            payerIndex = payer
            selectedPeople = players
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
