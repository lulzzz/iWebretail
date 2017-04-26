//
//  MovementArticleProtocol.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 17/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

protocol MovementArticleProtocol {
	
	func getAll(id: Int64) throws -> [MovementArticle]
	
	func get(id: Int64) throws -> MovementArticle?
	
	func add(barcode: String, movementId: Int64) throws -> Bool
	
	func update(id: Int64, item: MovementArticle) throws
	
	func delete(id: Int64) throws

	func getProducts(search: String) throws -> [Product]

	func getArticles(productId: Int64) throws -> [ProductArticle]
}
