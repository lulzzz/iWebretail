//
//  CustomerRepository.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 29/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import CoreData

class CustomerRepository: CustomerProtocol {

	let appDelegate: AppDelegate
	lazy var context: NSManagedObjectContext = { return self.appDelegate.persistentContainer.viewContext }()
	
	init() {
		appDelegate = UIApplication.shared.delegate as! AppDelegate
	}
	
	func getAll(search: String) throws -> [Customer] {
		let request: NSFetchRequest<Customer> = Customer.fetchRequest()
		if !search.isEmpty {
			request.predicate = NSPredicate.init(format: "customerName LIKE[c] %@", search)
		}
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "customerName", ascending: true)
		request.sortDescriptors = [idDescriptor]
		
		return try context.fetch(request)
	}

	func get(id: Int64) throws -> Customer? {
		let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "customerId == \(id)")
		fetchRequest.fetchLimit = 1
		let object = try context.fetch(fetchRequest)
		
		return object.first
	}
	
	func add() throws -> Customer {
		let entity =  NSEntityDescription.entity(forEntityName: "Customer", in: context)
		let customer = Customer(entity: entity!, insertInto: context)
		customer.customerId = try self.newId()
		try context.save()
		
		return customer
	}
	
	func update(id: Int64, item: Customer) throws {
		let current = try self.get(id: id)!
		current.customerName = item.customerName
		current.customerEmail = item.customerEmail
		current.customerPhone = item.customerPhone
		current.customerAddress = item.customerAddress
		current.customerCity = item.customerCity
		current.customerZip = item.customerZip
		current.customerCountry = item.customerCountry
		current.customerFiscalCode = item.customerFiscalCode
		current.customerVatNumber = item.customerVatNumber
		current.updatedAt = Int64.now()
		try context.save()
	}
	
	func delete(id: Int64) throws {
		let item = try self.get(id: id)
		context.delete(item!)
		try context.save()
	}
	
	private func newId() throws -> Int64 {
		var newId: Int64 = -1;
		
		let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "customerId", ascending: true)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try context.fetch(fetchRequest)
		if(results.count == 1) {
			newId = results.first!.customerId - 1
		}
		
		return newId
	}
}
