//
//  MovementsController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 14/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import CoreData

class ProgressNotification {
	var current: Int = 0
	var total: Int = 0
}

class MovementsController: UITableViewController {

	@IBOutlet weak var progressView: UIProgressView!
	
	let kProgressViewTag = 10000
	
	var filtered = [String: [Movement]]()
	
	private let repository: MovementProtocol
	
	required init?(coder aDecoder: NSCoder) {
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as MovementProtocol

		super.init(coder: aDecoder)

		NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name(rawValue: kProgressUpdateNotification), object: nil)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

		self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
	}

	override func viewDidAppear(_ animated: Bool) {
		refresh(sender: self)
 	}
	
	func refresh(sender:AnyObject)
	{
		do {
			Synchronizer.shared.syncronize()
			filtered = try repository.getAll().groupBy { $0.movementDate!.formatDateShort() }
			self.tableView.reloadData()
		} catch {
			self.navigationController?.alert(title: "Error", message: "\(error)")
		}
		self.refreshControl?.endRefreshing()
	}
	
	func didReceiveNotification(notification:NSNotification) {
		if let progress = notification.object as? ProgressNotification {
			if progress.current == progress.total {
				DispatchQueue.main.async {
					self.progressView.setProgress(1.0, animated: false)
					self.progressView.setProgress(0.0, animated: false)
				}
			} else {
				let perc = Float(progress.current) / Float(progress.total)
				DispatchQueue.main.async {
					self.progressView.setProgress(perc, animated: false)
				}
			}
		}
	}

	// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		return self.filtered.count
    }

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Array(filtered.keys)[section]
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let key = Array(filtered.keys)[section]
		return filtered[key]!.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovementCell", for: indexPath)
		
		let key = Array(filtered.keys)[indexPath.section]
		let movement = filtered[key]![indexPath.row]

		cell.textLabel?.text = "\(movement.movementNumber)     \(movement.completed)"
		cell.detailTextLabel?.text = movement.movementAmount.formatCurrency()
        return cell
    }
	
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
	
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			do {
				let key = Array(filtered.keys)[indexPath.section]
				try repository.delete(id: filtered[key]![indexPath.row].movementId)
				self.filtered[key]!.remove(at: indexPath.row)
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
			let key = Array(filtered.keys)[indexPath!.section]
			Synchronizer.shared.movement = filtered[key]![indexPath!.row]
		}

		tabViewController.navigationItem.title = String(Synchronizer.shared.movement.movementNumber)
	}
}
