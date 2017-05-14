//
//  MovementArticleProtocol.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 17/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

protocol MovementArticleProtocol {
	
	func getAll(id: Int32) throws -> [MovementArticle]
	
	func get(id: Int32) throws -> MovementArticle?
	
	func add(barcode: String, movementId: Int32) throws -> Bool
	
	func update(id: Int32, item: MovementArticle) throws
	
	func delete(id: Int32) throws

	func getProducts() throws -> [Product]

	func getArticles(productId: Int32) throws -> [ProductArticle]
	
	func updateAmount(item: Movement, amount: Double)
}
