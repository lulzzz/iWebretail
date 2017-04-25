//
//  MovementProtocol.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 16/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

protocol MovementProtocol {
	
	func getAll() throws -> [Movement]
	
	func get(id: Int64) throws -> Movement?
	
	func newNumber() throws -> Int32
	
	func add() throws -> Movement
	
	func update(id: Int64, item: Movement) throws
	
	func delete(id: Int64) throws

	func getStore() throws -> Store

	func getCausals() throws -> [Causal]

	func getCustomers(search: String) throws -> [Customer]
}
