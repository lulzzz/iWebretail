//
//  CustomerProtocol.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 29/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

protocol CustomerProtocol {
	
	func getAll(search: String) throws -> [Customer]
	
	func get(id: Int64) throws -> Customer?
	
	func add() throws -> Customer
	
	func update(id: Int64, item: Customer) throws
	
	func delete(id: Int64) throws
}
