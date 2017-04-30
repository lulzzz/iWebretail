//
//  Syncronizer.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 17/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import CoreData


typealias ServiceResponse = (Data?, Error?) -> Void

class Synchronizer {
	
	static let shared = Synchronizer()
	
	let baseURL = "http://ec2-35-157-208-60.eu-central-1.compute.amazonaws.com/"
	var token: String = ""
	
	// MARK: - webapi
	
	func makeHTTPGetRequest(url: String, onCompletion: @escaping ServiceResponse) {
		var request =  URLRequest(url: URL(string: baseURL + url)!)
		request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
		request.addValue("Bearer token=" + token, forHTTPHeaderField: "Authorization")
		request.httpMethod = "GET"
		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			data, response, error -> Void in
				onCompletion(data, error)
			})
		task.resume()
	}
	
	func makeHTTPPostRequest(url: String, body: NSDictionary, onCompletion: @escaping ServiceResponse) {
		var request =  URLRequest(url: URL(string: baseURL + url)!)
		request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
		request.addValue("Bearer token=" + token, forHTTPHeaderField: "Authorization")
		request.httpMethod = "POST"
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
		} catch let error as NSError {
			print(error)
		}
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			data, response, error -> Void in
				onCompletion(data, error)
			})
		task.resume()
	}
	
	func login() {
		let paramString = "username=admin&password=admin"
		
		var request =  URLRequest(url: URL(string: baseURL + "api/login")!)
		request.httpMethod = "POST"
		request.httpBody = paramString.data(using: String.Encoding.utf8)
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			data, response, error -> Void in
			if error != nil {
				print(error!.localizedDescription)
				return
			}

			let json = try! JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
			self.token = json["token"] as! String
		})
		task.resume()
	}

	func logout() {
		makeHTTPPostRequest(url: "api/logout", body: NSDictionary(), onCompletion:  { data, error in
			if error != nil {
				print(error!.localizedDescription)
			}
		})
	}
	
	func syncStore(context: NSManagedObjectContext) {
		let fetchRequest: NSFetchRequest<Store> = Store.fetchRequest()
		fetchRequest.fetchLimit = 1
		let objects = try! context.fetch(fetchRequest)
		let store = objects.count == 0 ? Store(context: context) : objects.first!

		makeHTTPGetRequest(url: "api/cashregisterfrom/\(store.updatedAt)", onCompletion: { data, error in
			if error != nil {
				print(error!.localizedDescription)
				return
			}
			
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options:.allowFragments) as! [NSDictionary]
					
					for item in items {
						if UIDevice.current.name == item["cashRegisterName"] as! String {
							store.setJSONValues(json: item["store"] as! NSDictionary)
							store.updatedAt = item["updatedAt"] as! Int64
							try context.save()
						}
					}
				} catch {
					print("Error on sync store: \(error)")
				}
			}
		})
	}

	func syncCausals(context: NSManagedObjectContext) {
		let fetchRequest: NSFetchRequest<Causal> = Causal.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 0
		
		makeHTTPGetRequest(url: "/api/causalfrom/\(date)", onCompletion: { data, error in
			if error != nil {
				print(error!.localizedDescription)
				return
			}
			
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options:.allowFragments) as! [NSDictionary]
					
					for (index, item) in items.enumerated() {
						let causal = Causal(context: context)
						causal.setJSONValues(json: item)
						try self.deleteCausalIfExist(id: causal.causalId, context: context)
						context.insert(causal)
						try context.save()
						self.notify(total: items.count, current: index + 1)
					}
				} catch {
					print("Error on sync causal: \(error)")
				}
			}
		})
	}

	func deleteCausalIfExist(id: Int16, context: NSManagedObjectContext) throws {
		let fetchRequest: NSFetchRequest<Causal> = Causal.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "causalId == \(id)")
		fetchRequest.fetchLimit = 1
		let object = try context.fetch(fetchRequest)
		if let item = object.first {
			context.delete(item)
			try context.save()
		}
	}

	func syncCustomers(context: NSManagedObjectContext) {
		let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 0
		
		makeHTTPGetRequest(url: "/api/customerfrom/\(date)", onCompletion: { data, error in
			if error != nil {
				print(error!.localizedDescription)
				return
			}
			
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options:.allowFragments) as! [NSDictionary]
					
					for (index, item) in items.enumerated() {
						let customer = Customer(context: context)
						customer.setJSONValues(json: item)
						try self.deleteCustomerIfExist(id: customer.customerId, context: context)
						context.insert(customer)
						try context.save()
						self.notify(total: items.count, current: index + 1)
					}
				} catch {
					print("Error on sync customer: \(error)")
				}
			}
		})
	}

	func deleteCustomerIfExist(id: Int64, context: NSManagedObjectContext) throws {
		let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "customerId == \(id)")
		fetchRequest.fetchLimit = 1
		let object = try context.fetch(fetchRequest)
		if let item = object.first {
			context.delete(item)
			try context.save()
		}
	}

	func syncProducts(context: NSManagedObjectContext) {
		let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 0
		
		makeHTTPGetRequest(url: "/api/productfrom/\(date)", onCompletion: { data, error in
			if error != nil {
				print(error!.localizedDescription)
				return
			}
			
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options:.allowFragments) as! [NSDictionary]
					
					for (index, item) in items.enumerated() {
						let product = Product(context: context)
						product.setJSONValues(json: item)
						try self.deleteProductIfExist(id: product.productId, context: context)
						context.insert(product)
												
						for article in item["articles"] as! [NSDictionary] {
							let productArticle = ProductArticle(context: context)
							productArticle.productId = product.productId
							productArticle.setJSONValues(json: article, attributes: item["attributes"] as! [NSDictionary])
							context.insert(productArticle)
						}

						try context.save()
						self.notify(total: items.count, current: index + 1)
					}
				} catch {
					print("Error on sync product: \(error)")
				}
			}
		})
	}

	func deleteProductIfExist(id: Int64, context: NSManagedObjectContext) throws {
		let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "productId == \(id)")
		fetchRequest.fetchLimit = 1
		let object = try context.fetch(fetchRequest)
		if let item = object.first {
			context.delete(item)

			let request: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
			request.predicate = NSPredicate.init(format: "productId == \(id)")
			let rows = try context.fetch(request)
			for row in rows {
				context.delete(row)
			}
			
			try context.save()
		}
	}

	func notify(total: Int, current: Int) {
		let notification = ProgressNotification()
		notification.total = total
		notification.current = current
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: kProgressUpdateNotification), object: notification)
		}
	}

	func pull(date: Date) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		let appDel = UIApplication.shared.delegate as! AppDelegate
		let context = appDel.persistentContainer.viewContext
		
		self.syncStore(context: context)
		self.syncCausals(context: context)
		self.syncCustomers(context: context)
		self.syncProducts(context: context)
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}

	func push() {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		let appDel = UIApplication.shared.delegate as! AppDelegate
		let context = appDel.persistentContainer.viewContext
		
		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "completed == true AND synced == false")
		let items = try! context.fetch(fetchRequest)
		
		for item in items {
			
			let rowsRequest: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
			rowsRequest.predicate = NSPredicate.init(format: "movementId == \(item.movementId)")
			let rows = try! context.fetch(rowsRequest)

			makeHTTPPostRequest(url: "api/movement", body: item.getJSONValues(rows: rows), onCompletion:  { data, error in
				if error != nil {
					print(error!.localizedDescription)
				} else if let usableData = data {
					do {
						let json = try JSONSerialization.jsonObject(with: usableData, options:.allowFragments) as! NSDictionary
						item.movementNumber = json["movementNumber"] as! Int32
						item.synced = true
						try context.save()
					} catch {
						print("Error on sync movement: \(error)")
					}
				}
			})
		}
		
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
}
