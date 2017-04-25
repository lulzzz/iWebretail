//
//  ReceiptsViewController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 14/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import CoreData

class MovementsViewController: UITableViewController {

	var movements: [Movement]
	
	private let repository: MovementProtocol
	
	required init?(coder aDecoder: NSCoder) {
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as MovementProtocol
		
		self.movements = []
		
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

		Synchronizer.shared.pull(date: Date())
   	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	override func viewDidAppear(_ animated: Bool) {
		do {
			movements = try repository.getAll()
			self.tableView.reloadData()
		} catch {
			print("Error on movement getAll: \(error)")
		}
 	}
	
	
	// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Receipt", for: indexPath)
		
		cell.textLabel?.text = "\(movements[indexPath.row].movementNumber)"
		cell.detailTextLabel?.text = movements[indexPath.row].movementDate?.formatDateShort()
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
				print("Error on movement delete: \(error)")
			}
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let viewController: MovementViewController = segue.destination as! MovementViewController

		let indexPath = self.tableView?.indexPathForSelectedRow
		if (indexPath == nil) {
			do {
				viewController.movement = try repository.add()
			} catch {
				print("Error on movement add: \(error)")
			}
		} else {
			viewController.movement = self.movements[indexPath!.row]
		}

		viewController.title = String(viewController.movement.movementNumber)
	}
}
