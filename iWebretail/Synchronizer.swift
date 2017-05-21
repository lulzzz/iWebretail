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

typealias ServiceResponse = (Data?) -> Void
let kProgressUpdateNotification = "kProgressUpdateNotification"
//let kProgressViewTag = 10000

class Synchronizer {
	
	static let shared = Synchronizer()
	
	let service = IoCContainer.shared.resolve() as ServiceProtocol

	private let baseURL = "http://ec2-35-157-208-60.eu-central-1.compute.amazonaws.com/"
	private var deviceToken: String = ""
	var isSyncing: Bool = false
	var movement: Movement!
	
	func iCloudUserIDAsync() {
		let container = CKContainer.default()
		container.fetchUserRecordID() {
			recordID, error in
			if error != nil {
				self.service.push(title: "Attention", message: error!.localizedDescription)
			} else {
				self.deviceToken = recordID!.recordName
				//print("fetched ID \(self.deviceToken)")
			}
		}
	}
	
	func syncronize() {
		if deviceToken.isEmpty { return }
		
		isSyncing = true
		
		let fetchRequest: NSFetchRequest<Store> = Store.fetchRequest()
		fetchRequest.fetchLimit = 1
		let results = try! service.context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 0

		makeHTTPGetRequest(url: "api/devicefrom/\(date)", onCompletion: { data in
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
					
					for item in items {
						if self.deviceToken == item["deviceToken"] as! String {
							let store = results.count == 1 ? results.first! : Store(context: self.service.context)
							store.setJSONValues(json: item["store"] as! NSDictionary)
							store.updatedAt = item["updatedAt"] as! Int32
							self.service.save()
						}
					}
				} catch {
					self.service.push(title: "Error on sync store", message: error.localizedDescription)
				}
			}

			self.syncCausals()
		})
		
		while isSyncing {
			usleep(1000000)
		}
	}

	internal func syncCausals() {
		let fetchRequest: NSFetchRequest<Causal> = Causal.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! service.context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 1
		
		makeHTTPGetRequest(url: "/api/causalfrom/\(date)", onCompletion: { data in
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
					
					for item in items {

						let innerFetchRequest: NSFetchRequest<Causal> = Causal.fetchRequest()
						innerFetchRequest.predicate = NSPredicate.init(format: "causalId == \(item["causalId"] as! Int32)")
						innerFetchRequest.fetchLimit = 1
						let object = try self.service.context.fetch(innerFetchRequest)
						
						let causal = object.count == 1 ? object.first! : Causal(context: self.service.context)
						causal.setJSONValues(json: item)
					}
				} catch {
					self.service.push(title: "Error on sync causal", message: error.localizedDescription)
				}
				
				self.service.save()
			}
			
			self.syncCustomers()
		})
	}

	internal func syncCustomers() {
		let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! service.context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 1
		
		makeHTTPGetRequest(url: "/api/customerfrom/\(date)", onCompletion: { data in
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
					let itemCount = items.count

					for (index, item) in items.enumerated() {
						
						let innerFetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
						innerFetchRequest.predicate = NSPredicate.init(format: "customerId == \(item["customerId"] as! Int32)")
						innerFetchRequest.fetchLimit = 1
						let object = try self.service.context.fetch(innerFetchRequest)
						
						let customer = object.count == 1 ? object.first! : Customer(context: self.service.context)
						customer.setJSONValues(json: item)

						self.notify(total: itemCount, current: index + 1)
					}
				} catch {
					self.service.push(title: "Error on sync customer", message: error.localizedDescription)
				}

				self.service.save()
			}

			self.syncProducts()
		})
	}

	internal func syncProducts() {
		let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! service.context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 1
		
		makeHTTPGetRequest(url: "/api/productfrom/\(date)", onCompletion: { data in
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
					let itemCount = items.count
					
					for (index, item) in items.enumerated() {
						
						if item["productIsActive"] as! Bool {
							let innerFetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
							innerFetchRequest.predicate = NSPredicate.init(format: "productId == \(item["productId"] as! Int32)")
							innerFetchRequest.fetchLimit = 1
							let object = try self.service.context.fetch(innerFetchRequest)
							
							let product = object.count == 1 ? object.first! : Product(context: self.service.context)
							product.setJSONValues(json: item)

							for article in item["articles"] as! [NSDictionary] {

								let request: NSFetchRequest<ProductArticle> = ProductArticle.fetchRequest()
								request.predicate = NSPredicate.init(format: "articleBarcode == %@", article["articleBarcode"] as! String)
								request.fetchLimit = 1
								let rows = try self.service.context.fetch(request)
								
								let productArticle = rows.count == 1 ? rows.first! : ProductArticle(context: self.service.context)
								productArticle.setJSONValues(json: article, attributes: item["attributes"] as! [NSDictionary])
								productArticle.productId = product.productId
							}
						}
						
						self.notify(total: itemCount, current: index + 1)
					}
				} catch {
					self.service.push(title: "Error on sync product", message: error.localizedDescription)
				}

				self.service.save()
			}

			self.syncMovement()
		})
	}

	internal func syncMovement() {
		let fetchRequest: NSFetchRequest<Movement> = Movement.fetchRequest()
		fetchRequest.predicate = NSPredicate.init(format: "completed == true AND synced == false")
		let items = try! service.context.fetch(fetchRequest)
		let count = items.count
		if count == 0 {
			self.notify(total: 0, current: 0)
			self.isSyncing = false
			return
		}
		
		for (index, item) in items.enumerated() {
			let rowsRequest: NSFetchRequest<MovementArticle> = MovementArticle.fetchRequest()
			rowsRequest.predicate = NSPredicate.init(format: "movementId == \(item.movementId)")
			let rows = try! service.context.fetch(rowsRequest)
			
			makeHTTPPostRequest(url: "api/movement", body: item.getJSONValues(rows: rows), onCompletion:  { data in
				if let usableData = data {
					do {
						let json = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! NSDictionary
						item.movementNumber = json["movementNumber"] as! Int32
						item.synced = true
					} catch {
						self.service.push(title: "Error on sync movement", message: error.localizedDescription)
					}

					if index + 1 == count {
						self.isSyncing = false
						self.service.save()
					}

					self.notify(total: count, current: index + 1)
				}
			})
		}
	}

	internal func makeHTTPGetRequest(url: String, onCompletion: @escaping ServiceResponse) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true

		var request =  URLRequest(url: URL(string: baseURL + url)!)
		request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
		request.addValue("Basic \(UIDevice.current.name):\(self.deviceToken)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "GET"
		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			data, response, error -> Void in
			if self.onResponse(response: response as? HTTPURLResponse, error: error) {
				onCompletion(data)
			}
		})
		task.resume()
	}
	
	internal func makeHTTPPostRequest(url: String, body: NSDictionary, onCompletion: @escaping ServiceResponse) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true

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
			if self.onResponse(response: response as? HTTPURLResponse, error: error) {
				onCompletion(data)
			}
		})
		task.resume()
	}

	internal func onResponse(response: HTTPURLResponse?, error: Error?) -> Bool {
		UIApplication.shared.isNetworkActivityIndicatorVisible = false

		if error != nil {
			self.isSyncing = false
			service.push(title: "Error", message: error!.localizedDescription)
			return false
		}
		if response!.statusCode == 401 {
			self.isSyncing = false
			service.push(title: "Unauthorized", message: "Access is denied due to invalid credentials")
			return false
		}
		return true
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
