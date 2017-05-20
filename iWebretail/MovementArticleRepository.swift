//
//  MovementArticleRepository.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 17/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import CoreData

class MovementArticleRepository: MovementArticleProtocol {
	
	private let service: ServiceProtocol
	
	init() {
		service = IoCContainer.shared.resolve() as ServiceProtocol
	}

	func getAll(id: Int32) throws -> [MovementArticle] {
		let fetchRequest: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "movementId == \(id)")
		
		return try service.context.fetch(fetchRequest)
	}
	
	func get(id: Int32) throws -> MovementArticle? {
		let fetchRequest: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "movementArticleId == \(id)")
		fetchRequest.fetchLimit = 1
		let object = try service.context.fetch(fetchRequest)
		
		return object.first
	}
	
	func add(barcode: String, movementId: Int32) throws -> Bool {
		let movementArticleRequest: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
		movementArticleRequest.predicate = NSPredicate.init(format: "movementId == %@ AND movementArticleBarcode == %@", argumentArray: [movementId, barcode])
		movementArticleRequest.fetchLimit = 1
		let movementArticles = try service.context.fetch(movementArticleRequest)
		if movementArticles.count == 0 {
			let articleRequest: NSFetchRequest<ProductArticle> = ProductArticle.fetchRequest()
			articleRequest.predicate = NSPredicate.init(format: "articleBarcode == %@", barcode)
			articleRequest.fetchLimit = 1
			let articles = try service.context.fetch(articleRequest)
			if articles.count == 0 {
				return false
			}
			
			let article = articles.first!
			let productRequest: NSFetchRequest<Product> = Product.fetchRequest()
			productRequest.predicate = NSPredicate.init(format: "productId == \(article.productId)")
			productRequest.fetchLimit = 1
			let products = try service.context.fetch(productRequest)
			let product = products.first!

			let movementArticle = MovementArticle(context: service.context)
			movementArticle.movementId = movementId
			movementArticle.movementArticleId = try self.newId()
			movementArticle.movementArticleBarcode = barcode
			movementArticle.movementProduct = article.articleAttributes
			movementArticle.movementArticleQuantity = 1
			movementArticle.movementArticlePrice = product.productDiscount > 0 ? product.productDiscount : product.productSelling
		} else {
			let movementArticle = movementArticles.first!
			movementArticle.movementArticleQuantity += 1
		}
		
		try service.context.save()
		
		return true
	}
	
	func update(id: Int32, item: MovementArticle) throws {
		let current = try self.get(id: id)!
		current.movementArticleQuantity = item.movementArticleQuantity
		current.movementArticlePrice = item.movementArticlePrice
		service.saveContext()
	}
	
	func delete(id: Int32) throws {
		let item = try self.get(id: id)
		service.context.delete(item!)
		try service.context.save()
	}

	func newId() throws -> Int32 {
		var newId: Int32 = 1;
		
		let fetchRequest = NSFetchRequest<MovementArticle>(entityName: "MovementArticle")
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "movementArticleId", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try service.context.fetch(fetchRequest)
		if(results.count == 1) {
			newId = results.first!.movementArticleId + 1
		}
		
		return newId
	}

//	func getProducts() throws -> [Product] {
//		let request: NSFetchRequest<Product> = Product.fetchRequest()
//		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "productName", ascending: true)
//		request.sortDescriptors = [idDescriptor]
//		
//		return try context.fetch(request)
//	}
	
	func getProducts(search: String) throws -> [(key:String, value:[Product])] {
		let request: NSFetchRequest<Product> = Product.fetchRequest()
		if !search.isEmpty {
			request.predicate = NSPredicate.init(
				format: "productCode contains %@ OR productName contains %@ OR productCategories contains %@",
				search, search, search)
		}
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "productName", ascending: true)
		request.sortDescriptors = [idDescriptor]
		
		return try service.context.fetch(request)
			.groupBy { $0.productBrand! }
			.sorted { $0.key < $1.key }
	}

	func getArticles(productId: Int32) throws -> [ProductArticle] {
		let request: NSFetchRequest<ProductArticle> = ProductArticle.fetchRequest()
		request.predicate = NSPredicate.init(format: "productId == \(productId)")
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "articleId", ascending: true)
		request.sortDescriptors = [idDescriptor]
		
		return try service.context.fetch(request)
	}

	func updateAmount(item: Movement, amount: Double) throws {
		item.movementAmount = amount
		try service.context.save()
	}
}
