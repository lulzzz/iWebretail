//
//  FirstViewController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 12/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class MovementViewController: UITableViewController {
	
	var movement: Movement!
	var movementArticles: [MovementArticle]
	
	private var repository: MovementArticleProtocol

	required init?(coder aDecoder: NSCoder) {
		self.movementArticles = []
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as MovementArticleProtocol
		
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewDidAppear(_ animated: Bool) {
		self.movementArticles = try! repository.getAll(id: movement.movementId)
		tableView.reloadData()
	}
	
	@IBAction func stepperValueChanged(_ sender: UIStepper) {
		let point = sender.convert(CGPoint(x: 0, y: 0), to: tableView)
		let indexPath = self.tableView.indexPathForRow(at: point)!
		let item = movementArticles[indexPath.row]
		let cell = tableView.cellForRow(at: indexPath) as! ArticleViewCell
		
		item.movementArticleQuantity = sender.value
		cell.textQuantity.text = String(sender.value)
		cell.textAmount.text = String(item.movementArticleQuantity * item.movementArticlePrice)
		
		 try! repository.update(id: item.movementArticleId, item: item)
	}
	
	@IBAction func textValueChanged(_ sender: UITextField) {
		let point = sender.convert(CGPoint(x: 0, y: 0), to: tableView)
		let indexPath = self.tableView.indexPathForRow(at: point)!
		let item = movementArticles[indexPath.row]
		let cell = tableView.cellForRow(at: indexPath) as! ArticleViewCell
		
		if sender == cell.textQuantity {
			item.movementArticleQuantity = Double(sender.text!)!
			cell.stepperQuantity.value = item.movementArticleQuantity
		} else {
			item.movementArticlePrice = Double(sender.text!)!
		}		
		cell.textAmount.text = String(item.movementArticleQuantity * item.movementArticlePrice)

		try! repository.update(id: item.movementArticleId, item: item)
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return movementArticles.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleViewCell
		
		let index = (indexPath as NSIndexPath).row
		let item = movementArticles[index]
		
		// Configure the cell...
		cell.tag = index
		cell.labelBarcode.text = item.movementArticleBarcode
		cell.labelName.text = item.movementProduct
		cell.textPrice.text = String(item.movementArticlePrice)
		cell.textQuantity.text = String(item.movementArticleQuantity)
		cell.textAmount.text = String(item.movementArticleQuantity * item.movementArticlePrice)
		cell.stepperQuantity.value = item.movementArticleQuantity
		
		return cell
	}
	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			do {
				try repository.delete(id: self.movementArticles[indexPath.row].movementArticleId)
				self.movementArticles.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .fade)
			} catch {
				print("Error on article delete: \(error)")
			}
		}
	}

	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "RegisterView" {
			let viewController = segue.destination as! RegisterViewController
			viewController.movement = self.movement
		} else {
			let viewController = segue.destination as! BarcodeViewController
			viewController.movement = self.movement
		}
	}
}

