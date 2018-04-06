//
//  SheetsViewController.swift
//  Sheet
//
//  Created by Jeffrey Rosenbluth on 12/24/17.
//  Copyright © 2017 Applause Code. All rights reserved.
//

import UIKit

protocol SheetsDelegate: class {
    func dataChanged(_ sheet: String)
}

class SheetsViewController: UITableViewController, UITextFieldDelegate {
    
    weak var delegate: SheetsDelegate?
    
    var sheetNames: [String] = []
    var selection: String?
    var nameField = UITextField()
    var sheetIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        sheetNames = UserDefaults.standard.object(forKey:"SavedSheets") as? [String] ?? [String]()
        let addSheetButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSheetTapped))
        navigationItem.rightBarButtonItem = addSheetButton
        let loadSheetButton = UIBarButtonItem(title: "Open", style: .plain,  target: self, action: #selector(loadSheetTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        loadSheetButton.tintColor = UIColor(named: "dollarGreen")
        editButtonItem.tintColor = UIColor(named: "dollarGreen")
        toolbarItems = [loadSheetButton, space, editButtonItem]
        self.clearsSelectionOnViewWillAppear = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    @objc func addSheetTapped() {
        let addSheetController = UIAlertController(title: "New Sheet", message: nil, preferredStyle: .alert)
        
        func getName(t: UITextField) {
            t.placeholder = "Sheet Name"
            t.clearButtonMode = .always
            t.delegate = self
        }
        
        func add(a: UIAlertAction) {
            if let name = addSheetController.textFields?[0].text {
                if name != ""  {
                    sheetNames.append(name)
                    UserDefaults.standard.set(sheetNames, forKey: "SavedSheets")
                    tableView.reloadData()
                }
            }
        }
        addSheetController.addTextField(configurationHandler: getName)
        nameField = addSheetController.textFields![0]
        addSheetController.addAction(UIAlertAction(title: "Add", style: .default, handler: add))
        addSheetController.addAction((UIAlertAction(title: "Cancel", style: .cancel, handler: nil)))
        addSheetController.preferredAction = addSheetController.actions[0]
        present(addSheetController, animated: true)
    }
    
    @objc func loadSheetTapped() {
        if selection != nil {
            delegate?.dataChanged(selection!)
            UserDefaults.standard.set(sheetIndex, forKey: "Index")
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sheetNames.count)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = sheetNames[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection = sheetNames[indexPath.row]
        sheetIndex = indexPath.row
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            sheetNames.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            delete file with sheetname.
        }
    }
}
