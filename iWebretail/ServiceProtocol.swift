//
//  ServiceProtocol.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 20/05/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//
import CoreData

protocol ServiceProtocol {
	
	func push(title: String, message: String)

	var context: NSManagedObjectContext { get }
	
	func saveContext ()
}
