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

	private let service: ServiceProtocol
	
	init() {
		service = IoCContainer.shared.resolve() as ServiceProtocol
	}
	
	func getAll(search: String) throws -> [(key: String, value: [Customer])] {
		let request: NSFetchRequest<Customer> = Customer.fetchRequest()
		if !search.isEmpty {
			request.predicate = NSPredicate.init(format: "customerName contains %@", search)
		}
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "customerName", ascending: true)
		request.sortDescriptors = [idDescriptor]
		
		return try service.context.fetch(request)
			.groupBy { $0.customerName![$0.customerName!.startIndex].description }
			.sorted { $0.key < $1.key }
	}

	func get(id: Int32) throws -> Customer? {
		let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "customerId == \(id)")
		fetchRequest.fetchLimit = 1
		let object = try service.context.fetch(fetchRequest)
		
		return object.first
	}
	
	func add() throws -> Customer {
		let customer = Customer(context: service.context)
		customer.customerId = try self.newId()
		try service.context.save()
		
		return customer
	}
	
	func update(id: Int32, item: Customer) throws {
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
		current.updatedAt = Int32.now()
		try service.context.save()
	}
	
	func delete(id: Int32) throws {
		let item = try self.get(id: id)
		service.context.delete(item!)
		try service.context.save()
	}
	
	private func newId() throws -> Int32 {
		var newId: Int32 = -1;
		
		let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "customerId", ascending: true)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try service.context.fetch(fetchRequest)
		if(results.count == 1) {
			newId = results.first!.customerId - 1
		}
		
		return newId
	}
}
