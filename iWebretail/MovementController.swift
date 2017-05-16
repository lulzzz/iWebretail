//
//  MovementController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 12/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class MovementController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var amountLabel: UILabel!

	var movementArticles: [MovementArticle]
	
	private var repository: MovementArticleProtocol

	required init?(coder aDecoder: NSCoder) {
		self.movementArticles = []
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as MovementArticleProtocol
		
		super.init(coder: aDecoder)
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		self.tabBarController?.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem
		self.movementArticles = try! repository.getAll(id: Synchronizer.shared.movement.movementId)
		self.updateAmount()
		tableView.reloadData()
	}
	
	@IBAction func stepperValueChanged(_ sender: UIStepper) {
		let point = sender.convert(CGPoint(x: 0, y: 0), to: tableView)
		let indexPath = self.tableView.indexPathForRow(at: point)!
		let item = movementArticles[indexPath.row]
		let cell = tableView.cellForRow(at: indexPath) as! ArticleCell
		
		item.movementArticleQuantity = sender.value
		cell.textQuantity.text = String(sender.value)
		cell.textAmount.text = String(item.movementArticleQuantity * item.movementArticlePrice)
		
		try! repository.update(id: item.movementArticleId, item: item)
		self.updateAmount()
	}
	
	@IBAction func textValueChanged(_ sender: UITextField) {
		let point = sender.convert(CGPoint(x: 0, y: 0), to: tableView)
		let indexPath = self.tableView.indexPathForRow(at: point)!
		let item = movementArticles[indexPath.row]
		let cell = tableView.cellForRow(at: indexPath) as! ArticleCell
		
		if sender == cell.textQuantity {
			item.movementArticleQuantity = Double(sender.text!)!
			cell.stepperQuantity.value = item.movementArticleQuantity
		} else {
			item.movementArticlePrice = Double(sender.text!)!
		}		
		cell.textAmount.text = String(item.movementArticleQuantity * item.movementArticlePrice)

		try! repository.update(id: item.movementArticleId, item: item)
		self.updateAmount()
	}
	
	func updateAmount() {
		let amount = movementArticles
			.map { $0.movementArticleQuantity * $0.movementArticlePrice as Double }
			.reduce (0, +)
		amountLabel.text = amount.formatCurrency()
		
		repository.updateAmount(item: Synchronizer.shared.movement, amount: amount)
	}
	
	// MARK: - Table view data source
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return movementArticles.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
		
		let index = (indexPath as NSIndexPath).row
		let item = movementArticles[index]
		
		cell.labelBarcode.text = item.movementArticleBarcode
		cell.labelName.text = item.movementProduct
		cell.textPrice.text = String(item.movementArticlePrice)
		cell.textQuantity.text = String(item.movementArticleQuantity)
		cell.textAmount.text = String(item.movementArticleQuantity * item.movementArticlePrice)
		cell.stepperQuantity.value = item.movementArticleQuantity
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return !Synchronizer.shared.movement.completed
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			do {
				try repository.delete(id: self.movementArticles[indexPath.row].movementArticleId)
				self.movementArticles.remove(at: indexPath.row)
				self.updateAmount()
				tableView.deleteRows(at: [indexPath], with: .fade)
			} catch {
				self.navigationController?.alert(title: "Error", message: "\(error)")
			}
		}
	}
}

