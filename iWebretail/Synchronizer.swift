//
//  Syncronizer.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 17/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

typealias ServiceResponse = (Data?, Error?) -> Void

class Synchronizer {
	
	static let shared = Synchronizer()
	
	private let baseURL = "http://ec2-35-157-208-60.eu-central-1.compute.amazonaws.com/"
	private var deviceToken: String = ""
	var movement: Movement!

	func iCloudUserIDAsync() {
		let container = CKContainer.default()
		container.fetchUserRecordID() {
			recordID, error in
			if error != nil {
				print(error!.localizedDescription)
			} else {
				self.deviceToken = recordID!.recordName
				print("fetched ID \(self.deviceToken)")
			}
		}
	}
	
	func syncronize() {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true

		let appDel = UIApplication.shared.delegate as! AppDelegate
		let context = appDel.persistentContainer.viewContext

		self.push(context: context)
		self.pull(context: context, date: Date())

		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
	
	internal func pull(context: NSManagedObjectContext, date: Date) {
		self.syncStore(context: context)
		self.syncCausals(context: context)
		self.syncCustomers(context: context)
		self.syncProducts(context: context)
	}
	
	internal func push(context: NSManagedObjectContext) {
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
						let json = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! NSDictionary
						item.movementNumber = json["movementNumber"] as! Int32
						item.synced = true
						try context.save()
					} catch {
						print("Error on sync movement: \(error)")
					}
				}
			})
		}
	}
	
	internal func makeHTTPGetRequest(url: String, onCompletion: @escaping ServiceResponse) {
		var request =  URLRequest(url: URL(string: baseURL + url)!)
		request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
		request.addValue("Basic \(UIDevice.current.name):\(self.deviceToken)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "GET"
		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			data, response, error -> Void in
				onCompletion(data, error)
			})
		task.resume()
	}
	
	internal func makeHTTPPostRequest(url: String, body: NSDictionary, onCompletion: @escaping ServiceResponse) {
		var request =  URLRequest(url: URL(string: baseURL + url)!)
		request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
		request.addValue("Basic \(UIDevice.current.name):\(self.deviceToken)", forHTTPHeaderField: "Authorization")
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
	
	internal func syncStore(context: NSManagedObjectContext) {
		let fetchRequest: NSFetchRequest<Store> = Store.fetchRequest()
		fetchRequest.fetchLimit = 1
		let objects = try! context.fetch(fetchRequest)
		let store = objects.count == 0 ? Store(context: context) : objects.first!

		makeHTTPGetRequest(url: "api/devicefrom/\(store.updatedAt)", onCompletion: { data, error in
			if error != nil {
				print(error!.localizedDescription)
				return
			}
			
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
					
					for item in items {
						if self.deviceToken == item["deviceToken"] as! String {
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

	internal func syncCausals(context: NSManagedObjectContext) {
		let fetchRequest: NSFetchRequest<Causal> = Causal.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 1
		
		makeHTTPGetRequest(url: "/api/causalfrom/\(date)", onCompletion: { data, error in
			if error != nil {
				print(error!.localizedDescription)
				return
			}
			
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
					
					for (index, item) in items.enumerated() {

						let causal = Causal(context: context)
						causal.setJSONValues(json: item)

						let innerFetchRequest: NSFetchRequest<Causal> = Causal.fetchRequest()
						innerFetchRequest.predicate = NSPredicate.init(format: "causalId == \(causal.causalId)")
						let object = try context.fetch(innerFetchRequest)
						
						if object.count > 0 {
							let current = object.first!
							current.causalName = causal.causalName
							current.causalIsPos = causal.causalIsPos
							current.causalQuantity = causal.causalQuantity
							current.causalBooked = causal.causalBooked
							current.updatedAt = causal.updatedAt
						} else {
							context.insert(causal)
						}

						self.notify(total: items.count, current: index + 1)
					}

					try context.save()
				} catch {
					print("Error on sync causal: \(error)")
				}
			}
		})
	}

	internal func syncCustomers(context: NSManagedObjectContext) {
		let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 1
		
		makeHTTPGetRequest(url: "/api/customerfrom/\(date)", onCompletion: { data, error in
			if error != nil {
				print(error!.localizedDescription)
				return
			}
			
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
					
					for (index, item) in items.enumerated() {
						
						let customer = Customer(context: context)
						customer.setJSONValues(json: item)

						let innerFetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
						innerFetchRequest.predicate = NSPredicate.init(format: "customerId == \(customer.customerId)")
						let object = try context.fetch(innerFetchRequest)
						
						if object.count > 0 {
							let current = object.first!
							current.customerName = customer.customerName
							current.customerEmail = customer.customerEmail
							current.customerPhone = customer.customerPhone
							current.customerAddress = customer.customerAddress
							current.customerCity = customer.customerCity
							current.customerZip = customer.customerZip
							current.customerCountry = customer.customerCountry
							current.customerFiscalCode = customer.customerFiscalCode
							current.customerVatNumber = customer.customerVatNumber
							current.updatedAt = customer.updatedAt
						} else {
							context.insert(customer)
						}

						self.notify(total: items.count, current: index + 1)
					}
					
					try context.save()
				} catch {
					print("Error on sync customer: \(error)")
				}
			}
		})
	}

	internal func syncProducts(context: NSManagedObjectContext) {
		let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 1
		
		makeHTTPGetRequest(url: "/api/productfrom/\(date)", onCompletion: { data, error in
			if error != nil {
				print(error!.localizedDescription)
				return
			}
			
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
					
					for (index, item) in items.enumerated() {
						
						let product = Product(context: context)
						product.setJSONValues(json: item)
						
						let innerFetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
						innerFetchRequest.predicate = NSPredicate.init(format: "productId == \(product.productId)")
						let object = try context.fetch(innerFetchRequest)
						if object.count > 0 {
							let current = object.first!
							current.productName = product.productName
							current.productCode = product.productCode
							current.productUm = product.productUm
							current.productSelling = product.productSelling
							current.productDiscount = product.productDiscount
							current.productBrand = product.productBrand
							current.productCategories = product.productCategories
							current.updatedAt = product.updatedAt
						} else {
							context.insert(product)
						}
						
						for article in item["articles"] as! [NSDictionary] {
							let productArticle = ProductArticle(context: context)
							productArticle.productId = product.productId
							productArticle.setJSONValues(json: article, attributes: item["attributes"] as! [NSDictionary])

							let request: NSFetchRequest<ProductArticle> = ProductArticle.fetchRequest()
							request.predicate = NSPredicate.init(format: "articleBarcode == %@", productArticle.articleBarcode!)
							let rows = try context.fetch(request)
							if rows.count > 0 {
								let row = rows.first!
								productArticle.articleAttributes = row.articleAttributes
							} else {
								context.insert(productArticle)
							}
						}

						self.notify(total: items.count, current: index + 1)
					}

					try context.save()
				} catch {
					print("Error on sync product: \(error)")
				}
			}
		})
	}

	internal func notify(total: Int, current: Int) {
		let notification = ProgressNotification()
		notification.total = total
		notification.current = current
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: kProgressUpdateNotification), object: notification)
		}
	}
}
