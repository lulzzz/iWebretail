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
        // Dispose of any resources that can be recreated.
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.movements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Receipt", for: indexPath)
		
		cell.textLabel?.text = "\(self.movements[indexPath.row].movementNumber)"
		cell.detailTextLabel?.text = dateFormatter.string(for: self.movements[indexPath.row].movementDate)
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
			deleteMovement(id: self.movements[indexPath.row].movementNumber)
			self.movements.remove(at: indexPath.row)
			// Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        //} else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

	/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	func deleteMovement(id: Int32) {
		let context = Shared.shared.getContext()

		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "movementNumber==\(id)")
		let object = try! context.fetch(fetchRequest)
		context.delete(object.first!)
		
		do {
			try context.save()
		} catch {
			print("Error on deleteMovement: \(error)")
		}
	}
}
