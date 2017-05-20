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
	
	var filtered = [(key:String, value:[Movement])]()
	
	private let repository: MovementProtocol
	
	required init?(coder aDecoder: NSCoder) {
		repository = IoCContainer.shared.resolve() as MovementProtocol

		super.init(coder: aDecoder)

		NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name(rawValue: kProgressUpdateNotification), object: nil)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

		self.refreshControl?.addTarget(self, action: #selector(synchronize), for: UIControlEvents.valueChanged)
	}

	override func viewDidAppear(_ animated: Bool) {
		refreshData()
 	}
	
	func synchronize(sender:AnyObject)
	{
		//TODO: make this awaitable
		DispatchQueue.global(qos: .background).async {
			
			Synchronizer.shared.syncronize()

			while Synchronizer.shared.isSyncing {
				//print(Synchronizer.shared.isSyncing)
			}
			
			DispatchQueue.main.async {
				self.refreshControl?.endRefreshing()
				self.refreshData()
			}
		}
	}
	
	func refreshData() {
		do {
			filtered = try repository.getAllGrouped()
//									 .groupBy { $0.movementDate!.formatDateShort() }
//									 .sorted { $0.key < $1.key }
			self.tableView.reloadData()
		} catch {
			self.navigationController?.alert(title: "Error", message: "\(error)")
		}
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
		return filtered[section].key
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filtered[section].value.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovementCell", for: indexPath)
		
		let movement = filtered[indexPath.section].value[indexPath.row]
		if movement.synced {
			cell.imageView?.image = UIImage.init(named: "sync")
		} else if movement.completed {
			cell.imageView?.image = UIImage.init(named: "tosync")
		} else {
			cell.imageView?.image = UIImage.init(named: "build")
		}
		cell.textLabel?.text = "\(movement.movementCausal?.getJSONValues()["causalName"] ?? "New") n° \(movement.movementNumber)"
		cell.detailTextLabel?.text = "\(movement.movementCustomer?.getJSONValues()["customerName"] ?? "nobody") - \(movement.movementAmount.formatCurrency())"
        return cell
    }
	
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
	
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			do {
				try repository.delete(id: filtered[indexPath.section].value[indexPath.row].movementId)
				self.filtered[indexPath.section].value.remove(at: indexPath.row)
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
			Synchronizer.shared.movement = filtered[indexPath!.section].value[indexPath!.row]
		}

		tabViewController.navigationItem.title = String(Synchronizer.shared.movement.movementNumber)
	}
}
