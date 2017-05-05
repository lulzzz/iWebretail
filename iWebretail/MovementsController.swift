//
//  ReceiptsViewController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 14/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import CoreData

class MovementsController: UITableViewController {

	var movements: [Movement] = []
	
	private let repository: MovementProtocol
	
	required init?(coder aDecoder: NSCoder) {
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as MovementProtocol
		
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

		self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
   	}

//	override func viewDidAppear(_ animated: Bool) {
//		self.refresh(sender: self)
// 	}
	
	func refresh(sender:AnyObject)
	{
		do {
			Synchronizer.shared.push()
			Synchronizer.shared.pull(date: Date())
			movements = try repository.getAll()
			self.tableView.reloadData()
		} catch {
			self.navigationController?.alert(title: "Error", message: "\(error)")
		}
		self.refreshControl?.endRefreshing()
	}
	
	// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovementCell", for: indexPath)
		
		cell.textLabel?.text = "\(movements[indexPath.row].movementNumber)     \(movements[indexPath.row].movementDate!.formatDateInput())"
		cell.detailTextLabel?.text = movements[indexPath.row].movementAmount.formatCurrency()
        return cell
    }
	
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
	
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			do {
				try repository.delete(id: self.movements[indexPath.row].movementId)
				self.movements.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .fade)
			} catch {
				self.navigationController?.alert(title: "Error", message: "\(error)")
			}
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let tabViewController: UITabBarController = segue.destination as! UITabBarController
		
		let indexPath = self.tableView?.indexPathForSelectedRow
		if (indexPath == nil) {
			do {
				Synchronizer.shared.movement = try repository.add()
			} catch {
				self.navigationController?.alert(title: "Error", message: "\(error)")
			}
		} else {
			Synchronizer.shared.movement = self.movements[indexPath!.row]
		}

		tabViewController.navigationItem.title = String(Synchronizer.shared.movement.movementNumber)
	}
}
