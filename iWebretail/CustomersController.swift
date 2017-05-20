//
//  CustomersController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 24/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class CustomersController: UITableViewController, UISearchBarDelegate {

	@IBOutlet weak var searchBar: UISearchBar!
	
	var customers = [(key: String, value: [Customer])]()
	private let repository: CustomerProtocol
	
	required init?(coder aDecoder: NSCoder) {
		repository = IoCContainer.shared.resolve() as CustomerProtocol
		
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.contentOffset = CGPoint(x: 0, y: 44)
		searchBar.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		customers = try! repository.getAll(search: "")
		self.tableView.reloadData()
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		customers = try! repository.getAll(search: searchText)
		self.tableView.reloadData()
	}

	// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return customers.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customers[section].value.count
    }

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return customers[section].key
	}

	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return customers.map { $0.key }
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath)

		let item = customers[indexPath.section].value[indexPath.row]
		cell.textLabel?.text = item.customerName
		cell.detailTextLabel?.text = item.customerEmail

        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let movement = Synchronizer.shared.movement!
		if !movement.completed {
			let item = customers[indexPath.section].value[indexPath.row]
			movement.movementCustomer = item.getJSONValues().getJSONString()
			navigationController?.popViewController(animated: true)
		}
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let item = customers[indexPath.section].value[indexPath.row]
		let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
			do {
				try self.repository.delete(id: item.customerId)
				self.customers[indexPath.section].value.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .fade)
			} catch {
				self.navigationController?.alert(title: "Error", message: "\(error)")
			}
		}

		let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let vc = storyboard.instantiateViewController(withIdentifier: "CustomerView") as! CustomerController
			vc.customer = item
			self.navigationController!.pushViewController(vc, animated: true)
		}
		
		return [delete, edit]
	}
}
