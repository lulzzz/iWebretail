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
	
	private let service: ServiceProtocol
	
	init() {
		service = IoCContainer.shared.resolve() as ServiceProtocol
	}

//	func getAll() throws -> [Movement] {
//		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
//		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "movementId", ascending: true)
//		fetchRequest.sortDescriptors = [idDescriptor]
//		
//		return try service.context.fetch(fetchRequest)
//	}
	
	func getAllGrouped(date: Date?) throws -> [(key:String, value:[Movement])] {
		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
		if date != nil {
			fetchRequest.predicate = self.makeDayPredicate(date: date!)
		}
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "movementNumber", ascending: true)
		fetchRequest.sortDescriptors = [idDescriptor]
		
		return try service.context.fetch(fetchRequest)
			.groupBy { $0.movementDate!.formatDateShort() }
			.sorted { $0.key > $1.key }
	}

	func get(id: Int32) throws -> Movement? {
		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "movementId == \(id)")
		fetchRequest.fetchLimit = 1
		let object = try service.context.fetch(fetchRequest)
		
		return object.first
	}
	
	func add() throws -> Movement {
		let causals = try getCausals();
		let causal = causals.first(where: { $0.causalIsPos })
		
		let movement = Movement(context: service.context)
		movement.movementId = try self.newId()
		movement.movementNumber = try self.newNumber(isPos: causal?.causalIsPos ?? false)
		movement.movementDate = NSDate()
		movement.movementStatus = "New"
		movement.movementCausal = causal?.getJSONValues().getJSONString()
		movement.completed = false
		movement.synced = false
		try service.context.save()
		
		return movement
	}
	
	func update(id: Int32, item: Movement) throws {
		let current = try self.get(id: id)!
		current.movementNumber = item.movementNumber
		current.movementDate = item.movementDate
		current.movementStore = item.movementStore
		current.movementCausal = item.movementCausal
		current.movementCustomer = item.movementCustomer
		current.movementPayment = item.movementPayment
		current.movementDevice = item.movementDevice
		current.movementNote = item.movementNote
		current.completed = item.completed
		
		try service.context.save()
	}
	
	func delete(id: Int32) throws {
		let item = try self.get(id: id)
		service.context.delete(item!)

		let fetchRequest: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "movementId == \(id)")
		let rows = try service.context.fetch(fetchRequest)
		for row in rows {
			service.context.delete(row)
		}

		try service.context.save()
	}

	func newId() throws -> Int32 {
		var newId: Int32 = 1;
		
		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "movementId", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try service.context.fetch(fetchRequest)
		if(results.count == 1) {
			newId = results.first!.movementId + 1
		}
		
		return newId
	}
	
	func newNumber(isPos: Bool) throws -> Int32 {
		
		if !isPos {
			return 0
		}
		
		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
		fetchRequest.predicate = self.makeDayPredicate(date: Date())
		let items = try service.context.fetch(fetchRequest)
		let max = items.max { $0.movementNumber < $1.movementNumber }
		
		return max == nil ? 1 : max!.movementNumber + 1
	}

	func makeDayPredicate(date: Date) -> NSPredicate {
		var calendar = Calendar.current
		calendar.timeZone = TimeZone(identifier: "UTC")!
		var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
		components.hour = 00
		components.minute = 00
		components.second = 00
		let startDate = calendar.date(from: components)
		components.hour = 23
		components.minute = 59
		components.second = 59
		let endDate = calendar.date(from: components)
		
		return NSPredicate(format: "movementDate >= %@ AND movementDate =< %@ AND movementCausal contains %@", argumentArray: [startDate!, endDate!, "true"])
	}

	func getStore() throws -> Store? {
		let request: NSFetchRequest<Store> = Store.fetchRequest()
		request.fetchLimit = 1
		let results = try service.context.fetch(request)
		
		return results.first
	}

	func getCausals() throws -> [Causal] {
		let request: NSFetchRequest<Causal> = Causal.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "causalIsPos", ascending: false)
		request.sortDescriptors = [idDescriptor]

		return try service.context.fetch(request)
	}

	func getPayments() -> [String] {
		return [
			"Cash",
			"Credit card",
			"Bank transfer",
			"Carrier",
			"None"
		]
	}
}
