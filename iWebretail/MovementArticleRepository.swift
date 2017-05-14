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
	
	let appDelegate: AppDelegate
	lazy var context: NSManagedObjectContext = { return self.appDelegate.persistentContainer.viewContext }()
	
	init() {
		appDelegate = UIApplication.shared.delegate as! AppDelegate
	}

	func getAll(id: Int64) throws -> [MovementArticle] {
		let fetchRequest: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "movementId == \(id)")
		
		return try context.fetch(fetchRequest)
	}
	
	func get(id: Int64) throws -> MovementArticle? {
		let fetchRequest: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "movementArticleId == \(id)")
		fetchRequest.fetchLimit = 1
		let object = try context.fetch(fetchRequest)
		
		return object.first
	}
	
	func add(barcode: String, movementId: Int64) throws -> Bool {
		let movementArticleRequest: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
		movementArticleRequest.predicate = NSPredicate.init(format: "movementArticleBarcode == %@", barcode)
		movementArticleRequest.fetchLimit = 1
		let movementArticles = try context.fetch(movementArticleRequest)
		if movementArticles.count == 0 {
			let articleRequest: NSFetchRequest<ProductArticle> = ProductArticle.fetchRequest()
			articleRequest.predicate = NSPredicate.init(format: "articleBarcode == %@", barcode)
			articleRequest.fetchLimit = 1
			let articles = try context.fetch(articleRequest)
			if articles.count == 0 {
				return false
			}
			
			let article = articles.first!
			let productRequest: NSFetchRequest<Product> = Product.fetchRequest()
			productRequest.predicate = NSPredicate.init(format: "productId == \(article.productId)")
			productRequest.fetchLimit = 1
			let products = try context.fetch(productRequest)

			let entity =  NSEntityDescription.entity(forEntityName: "MovementArticle", in: context)
			let movementArticle = MovementArticle(entity: entity!, insertInto: context)
			movementArticle.movementId = movementId
			movementArticle.movementArticleId = try self.newId()
			movementArticle.movementArticleBarcode = barcode
			movementArticle.movementProduct = article.articleAttributes
			movementArticle.movementArticleQuantity = 1
			movementArticle.movementArticlePrice = (products.first?.productSelling)!
		} else {
			let movementArticle = movementArticles.first!
			movementArticle.movementArticleQuantity += 1
		}
		
		appDelegate.saveContext()
		
		return true
	}
	
	func update(id: Int64, item: MovementArticle) throws {
		let current = try self.get(id: id)!
		current.movementArticleQuantity = item.movementArticleQuantity
		current.movementArticlePrice = item.movementArticlePrice
		appDelegate.saveContext()
	}
	
	func delete(id: Int64) throws {
		let item = try self.get(id: id)
		context.delete(item!)
		appDelegate.saveContext()
	}

	func newId() throws -> Int64 {
		var newId: Int64 = 1;
		
		let fetchRequest = NSFetchRequest<MovementArticle>(entityName: "MovementArticle")
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "movementArticleId", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try context.fetch(fetchRequest)
		if(results.count == 1) {
			newId = results.first!.movementId + 1
		}
		
		return newId
	}

	func getProducts(search: String = "") throws -> [Product] {
		let request: NSFetchRequest<Product> = Product.fetchRequest()
		if !search.isEmpty {
			request.predicate = NSPredicate.init(
				format: "productCode LIKE[c] %@ OR productName LIKE[c] %@ OR productCategories LIKE[c] %@",
				search, search, search)
		}
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "productName", ascending: true)
		request.sortDescriptors = [idDescriptor]
		
		return try context.fetch(request)
	}

	func getArticles(productId: Int64) throws -> [ProductArticle] {
		let request: NSFetchRequest<ProductArticle> = ProductArticle.fetchRequest()
		request.predicate = NSPredicate.init(format: "productId == \(productId)")
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "articleAttributes", ascending: true)
		request.sortDescriptors = [idDescriptor]
		
		return try context.fetch(request)
	}

	func updateAmount(item: Movement, amount: Double) {
		item.movementAmount = amount
		appDelegate.saveContext()
	}
}
