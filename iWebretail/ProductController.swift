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
	var filtered: [String: [Product]]!
	private let repository: MovementArticleProtocol
	
	required init?(coder aDecoder: NSCoder) {
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as MovementArticleProtocol
		
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.contentOffset = CGPoint(x: 0, y: 44)
		searchBar.delegate = self

		products = try! repository.getProducts(search: "")
		filtered = products.groupBy { $0.productBrand! }

		self.tableView.reloadData()
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.isEmpty {
			filtered = products.groupBy { $0.productBrand! }
		} else {
			filtered = products.filter({ (item) -> Bool in
				let tmp: Product = item
				return tmp.productName!.contains(searchText)
			}).groupBy { $0.productBrand! }
		}
		self.tableView.reloadData()
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return filtered.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Array(filtered.keys)[section]
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let key = Array(filtered.keys)[section]
		return filtered[key]!.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
		
		let key = Array(filtered.keys)[indexPath.section]
		cell.textLabel?.text = filtered[key]![indexPath.row].productName
		cell.detailTextLabel?.text = filtered[key]![indexPath.row].productCategories
		
		return cell
	}

	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let articleController: ArticleController = segue.destination as! ArticleController
		
		let indexPath = self.tableView?.indexPathForSelectedRow
		let key = Array(filtered.keys)[indexPath!.section]
		articleController.product = filtered[key]![indexPath!.row]
	}
}
