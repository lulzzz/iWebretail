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
	
	var products = [(key: String, value:[Product])]()
	private let repository: MovementArticleProtocol
	
	required init?(coder aDecoder: NSCoder) {
		repository = IoCContainer.shared.resolve() as MovementArticleProtocol
		
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.contentOffset = CGPoint(x: 0, y: 44)
		searchBar.delegate = self

		products = try! repository.getProducts(search: "")
		self.tableView.reloadData()
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		products = try! repository.getProducts(search: searchBar.text!)
		self.tableView.reloadData()
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return products.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return products[section].key
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return products[section].value.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
		
		let product = products[indexPath.section].value[indexPath.row]
		
		cell.textLabel?.text = product.productName!
		var text = product.productCategories! + " - " + product.productSelling.formatCurrency()
		if product.productDiscount > 0 {
			text += " -> " + product.productDiscount.formatCurrency()
		}
		cell.detailTextLabel?.text = text
		
		return cell
	}

	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let articleController: ArticleController = segue.destination as! ArticleController
		
		let indexPath = self.tableView?.indexPathForSelectedRow
		articleController.product = products[indexPath!.section].value[indexPath!.row]
	}
}
