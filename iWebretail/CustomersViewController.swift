//
//  CustomerViewController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 24/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class CustomersController: UITableViewController, UISearchBarDelegate {

	@IBOutlet weak var searchBar: UISearchBar!
	
	var movement: Movement!
	var customers: [Customer]!
	var filtered: [Customer]!
	private let repository: MovementProtocol
	
	required init?(coder aDecoder: NSCoder) {
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as MovementProtocol
		
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
        super.viewDidLoad()

		searchBar.delegate = self
		
		customers = try! repository.getCustomers(search: "")
		filtered = customers
		self.tableView.reloadData()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.isEmpty {
			filtered = customers
		} else {
			filtered = customers.filter({ (item) -> Bool in
				let tmp: Customer = item
				return tmp.customerName!.contains(searchText)
			})
		}
		self.tableView.reloadData()
	}
	
	// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath)

		cell.textLabel?.text = filtered[indexPath.row].customerName
		cell.detailTextLabel?.text = filtered[indexPath.row].customerEmail

        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		movement.movementCustomer = filtered[indexPath.row].getJSONValues().getJSONString()
		navigationController?.popViewController(animated: true)
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
			//self.isEditing = false
			print("edit button tapped")
		}
		edit.backgroundColor = UIColor.blue
		
		return [edit]
	}
	
	/*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
}
