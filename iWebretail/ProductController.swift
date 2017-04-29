//
//  ProductController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 29/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class ProductController: UITableViewController, UISearchBarDelegate {
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	var products: [Product]!
	var filtered: [Product]!
	public var movement: Movement!
	private let repository: MovementArticleProtocol
	
	required init?(coder aDecoder: NSCoder) {
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as MovementArticleProtocol
		
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		searchBar.delegate = self

		products = try! repository.getProducts(search: "")
		filtered = products
		self.tableView.reloadData()
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.isEmpty {
			filtered = products
		} else {
			filtered = products.filter({ (item) -> Bool in
				let tmp: Product = item
				return tmp.productName!.contains(searchText)
			})
		}
		self.tableView.reloadData()
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return filtered.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return filtered[section].productName
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		do {
			let items = try repository.getArticles(productId: filtered[section].productId)
			return items.count
		} catch {
			print("\(error)")
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
		
		do {
			let items = try repository.getArticles(productId: filtered[indexPath.section].productId)
			cell.textLabel?.text = items[indexPath.row].articleAttributes
			cell.detailTextLabel?.text = items[indexPath.row].articleBarcode
		} catch {
			print("\(error)")
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		do {
			let items = try repository.getArticles(productId: filtered[indexPath.section].productId)
			_ = try repository.add(barcode: items[indexPath.row].articleBarcode!, movementId: movement.movementId)
		} catch {
			print("\(error)")
		}

		if let composeViewController = self.navigationController?.viewControllers[1] {
			self.navigationController?.popToViewController(composeViewController, animated: true)
		}
	}
}
