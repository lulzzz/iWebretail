//
//  CustomerProtocol.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 29/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

protocol CustomerProtocol {
	
	func getAll(search: String) throws -> [(key: String, value: [Customer])]
	
	func get(id: Int32) throws -> Customer?
	
	func add() throws -> Customer
	
	func update(id: Int32, item: Customer) throws
	
	func delete(id: Int32) throws
}
