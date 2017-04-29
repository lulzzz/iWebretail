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
	private let repository: CustomerProtocol
	
	required init?(coder aDecoder: NSCoder) {
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as CustomerProtocol
		
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		searchBar.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		customers = try! repository.getAll(search: "")
		filtered = customers
		self.tableView.reloadData()
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
		let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
			do {
				try self.repository.delete(id: self.filtered[indexPath.row].customerId)
				self.filtered.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .fade)
			} catch {
				self.navigationController?.alert(title: "Error", message: "\(error)")
			}
		}

		let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let vc = storyboard.instantiateViewController(withIdentifier: "CustomerView") as! CustomerController
			vc.customer = self.filtered[indexPath.row]
			self.navigationController!.pushViewController(vc, animated: true)
		}
		
		return [delete, edit]
	}
}
