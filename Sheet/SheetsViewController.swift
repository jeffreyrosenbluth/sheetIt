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

    override func viewDidLoad() {
        super.viewDidLoad()
        sheetNames = UserDefaults.standard.object(forKey:"SavedSheets") as? [String] ?? [String]()
        let textColor = UIColor(red: 64/255, green: 128/255, blue: 0, alpha: 1)
        let addSheetButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSheetTapped))
        navigationItem.rightBarButtonItem = addSheetButton
        let loadSheetButton = UIBarButtonItem(title: "Open Sheet", style: .plain,  target: self, action: #selector(loadSheetTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addMemberButton = UIBarButtonItem(title: "Add Member", style: .plain, target: self, action: #selector(addMemberTapped))
        loadSheetButton.tintColor = textColor
        addMemberButton.tintColor = textColor
        toolbarItems = [loadSheetButton, space, addMemberButton]
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
            
        }
    }
    
    @objc func addMemberTapped() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sheetNames.count)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SheetName", for: indexPath)
        cell.textLabel?.text = sheetNames[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection = sheetNames[indexPath.row]
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
