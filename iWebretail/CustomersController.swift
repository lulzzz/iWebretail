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
	
	var letters: [String]!
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
		self.tableView.contentOffset = CGPoint(x: 0, y: 44)
		searchBar.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		customers = try! repository.getAll(search: "")
		filtered = customers
		self.loadLetters()
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
		self.loadLetters()
		self.tableView.reloadData()
	}
	
	func loadLetters() {
		letters = filtered.map { (item) -> String in
			return item.customerName![item.customerName!.startIndex].description
		}
	}

	func getCustomers(section: Int) -> [Customer] {
		return filtered.filter({ (item) -> Bool in
			let tmp: Customer = item
			return tmp.customerName!.hasPrefix(self.letters[section])
		})
	}
	// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return letters.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCustomers(section: section).count
    }

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return letters[section].description
	}

	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return self.letters
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath)

		let items = getCustomers(section: indexPath.section)
		cell.textLabel?.text = items[indexPath.row].customerName
		cell.detailTextLabel?.text = items[indexPath.row].customerEmail

        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let items = getCustomers(section: indexPath.section)
		Synchronizer.shared.movement.movementCustomer = items[indexPath.row].getJSONValues().getJSONString()
		navigationController?.popViewController(animated: true)
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let items = getCustomers(section: indexPath.section)
		let item = items[indexPath.row]
		let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
			do {
				try self.repository.delete(id: item.customerId)
				self.filtered.remove(at: self.filtered.index(of: item)!)
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
