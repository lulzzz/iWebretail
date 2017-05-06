//
//  ArticleController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 06/05/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class ArticleController: UITableViewController, UISearchBarDelegate {
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	var product: Product!
	var articles: [ProductArticle]!
	var filtered: [ProductArticle]!
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
		navigationItem.title = product.productName
		articles = try! repository.getArticles(productId: product.productId)
		filtered = articles
		self.tableView.reloadData()
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.isEmpty {
			filtered = articles
		} else {
			filtered = articles.filter({ (item) -> Bool in
				let tmp: ProductArticle = item
				return tmp.articleAttributes!.contains(searchText)
			})
		}
		self.tableView.reloadData()
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return articles.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
		
		let item = filtered[indexPath.row]
		cell.textLabel?.text = item.articleAttributes
		cell.detailTextLabel?.text = item.articleBarcode
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		do {
			_ = try repository.add(barcode: filtered[indexPath.row].articleBarcode!, movementId: Synchronizer.shared.movement.movementId)
		} catch {
			print("\(error)")
		}
		
		let composeViewController = self.navigationController?.viewControllers[1] as! UITabBarController
		composeViewController.selectedIndex = 0
		self.navigationController?.popToViewController(composeViewController, animated: true)
	}
}
