//
//  MovementRepository.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 16/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import CoreData

class MovementRepository: MovementProtocol {
	
	let context: NSManagedObjectContext;
	
	init() {
		let appDel = UIApplication.shared.delegate as! AppDelegate
		context = appDel.persistentContainer.viewContext
	}

	func getAll() throws -> [Movement] {
		let request: NSFetchRequest<Movement> = Movement.fetchRequest()
		
		return try context.fetch(request)
	}
	
	func get(id: Int64) throws -> Movement? {
		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "movementId==\(id)")
		fetchRequest.fetchLimit = 1
		let object = try! context.fetch(fetchRequest)
		
		return object.first
	}
	
	func add() throws -> Movement {
		let date = Date()
		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
		fetchRequest.predicate = self.makeDayPredicate(date: date)
		let items = try! context.fetch(fetchRequest)
		let max = items.max { $0.movementNumber < $1.movementNumber }
		
		//let movement = NSEntityDescription.insertNewObject(forEntityName: "Movement", into: context) as! Movement
		let entity =  NSEntityDescription.entity(forEntityName: "Movement", in: context)
		let movement = Movement(entity: entity!, insertInto: context)
		movement.movementId = try self.newId()
		movement.movementNumber = max == nil ? 1 : max!.movementNumber + 1
		movement.movementDate = date as NSDate
		try context.save()
		
		return movement
	}
	
	func update(id: Int64, item: Movement) throws {
		let current = try self.get(id: id)!
		current.movementNumber = item.movementNumber
		current.movementDate = item.movementDate
		current.movementStore = item.movementStore
		current.movementCausal = item.movementCausal
		current.movementCustomer = item.movementCustomer
		current.movementDevice = item.movementDevice
		current.movementNote = item.movementNote
		current.completed = item.completed
		
		try context.save()
	}
	
	func delete(id: Int64) throws {
		let item = try self.get(id: id)
		context.delete(item!)

		let fetchRequest: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "movementId==\(id)")
		let rows = try! context.fetch(fetchRequest)
		for row in rows {
			context.delete(row)
		}
		
		try context.save()
	}

	func newId() throws -> Int64 {
		var newId: Int64 = 1;
		
		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "movementId", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try context.fetch(fetchRequest)
		if(results.count == 1) {
			newId = results.first!.movementId + 1
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

	func getStore() throws -> Store {
		let request: NSFetchRequest<Store> = Store.fetchRequest()
		request.fetchLimit = 1
		let results = try context.fetch(request)
		
		return results.first!
	}

	func getCausals() throws -> [Causal] {
		let request: NSFetchRequest<Causal> = Causal.fetchRequest()

		return try context.fetch(request)
	}

	func getCustomers() throws -> [Customer] {
		let request: NSFetchRequest<Customer> = Customer.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "customerName", ascending: true)
		request.sortDescriptors = [idDescriptor]

		return try context.fetch(request)
	}
}
