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

	var movements: [Movement] = []
	let dateFormatter = DateFormatter()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		dateFormatter.dateStyle = .medium
   	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	override func viewDidAppear(_ animated: Bool) {
		self.movements = getMovements()
		self.tableView.reloadData()
 	}
	
	func getMovements() -> [Movement] {
		
		let request: NSFetchRequest<Movement> = Movement.fetchRequest()
		
		do {
			return try Shared.shared.getContext().fetch(request)
		} catch {
			print("Error with request: \(error)")
			return [Movement]()
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
		
		cell.textLabel?.text = "\(self.movements[indexPath.row].movementNumber)"
		cell.detailTextLabel?.text = dateFormatter.string(for: self.movements[indexPath.row].movementDate)
        return cell
    }
	
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
	
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			deleteMovement(id: self.movements[indexPath.row].movementId)
			self.movements.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let indexPath = self.tableView?.indexPathForSelectedRow
		if (indexPath == nil) {
			Shared.shared.movement = self.addMovement()
		} else {
			Shared.shared.movement = self.movements[indexPath!.row]
		}
		let viewController: MovementViewController = segue.destination as! MovementViewController
		viewController.title = String(Shared.shared.movement.movementNumber)
	}
	
	func newId() -> Int64 {
		var newId: Int64 = 1;

		let fetchRequest = NSFetchRequest<Movement>(entityName: "Movement")
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "movementId", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		do {
			let results = try Shared.shared.getContext().fetch(fetchRequest)
			if(results.count == 1) {
				newId = results.first!.movementId + 1
			}
		} catch {
			print("Error on new id: \(error)")
		}
		
		return newId
	}

	func makeDayPredicate(date: Date) -> NSPredicate {
		let calendar = Calendar.current
		var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
		components.hour = 00
		components.minute = 00
		components.second = 00
		let startDate = calendar.date(from: components)
		components.hour = 23
		components.minute = 59
		components.second = 59
		let endDate = calendar.date(from: components)
		return NSPredicate(format: "movementDate >= %@ AND movementDate =< %@", argumentArray: [startDate!, endDate!])
	}

	func addMovement() -> Movement {
		let context = Shared.shared.getContext()
		
		let date = Date()
		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
		fetchRequest.predicate = self.makeDayPredicate(date: date)
		let items = try! context.fetch(fetchRequest)
		let max = items.max { $0.movementNumber < $1.movementNumber }
		
		//let movement = NSEntityDescription.insertNewObject(forEntityName: "Movement", into: context) as! Movement
		let entity =  NSEntityDescription.entity(forEntityName: "Movement", in: context)
		let movement = Movement(entity: entity!, insertInto: context)
		movement.movementId = self.newId()
		movement.movementNumber = max == nil ? 1 : max!.movementNumber + 1
		movement.movementDate = date as NSDate
		
		do {
			try context.save()
		} catch {
			print("Error on add movement: \(error)")
		}
		
		return movement
	}

	func deleteMovement(id: Int64) {
		let context = Shared.shared.getContext()
		
		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "movementId==\(id)")
		fetchRequest.fetchLimit = 1
		let object = try! context.fetch(fetchRequest)
		context.delete(object.first!)
		
		do {
			try context.save()
		} catch {
			print("Error on delete movement: \(error)")
		}
	}
}
