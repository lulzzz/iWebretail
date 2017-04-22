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
	
	func makeHTTPPostRequest(url: String, body: [String: Any], onCompletion: @escaping ServiceResponse) {
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
		makeHTTPPostRequest(url: "api/logout", body: [String : Any](), onCompletion:  { data, error in
			if error != nil {
				print(error!.localizedDescription)
			}
		})
	}
	
	func syncStore(context: NSManagedObjectContext) {
		makeHTTPGetRequest(url: "api/cashregister", onCompletion: { data, error in
			if error != nil {
				print(error!.localizedDescription)
				return
			}
			
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options:.allowFragments) as! [NSDictionary]
					
					for item in items {
						if UIDevice.current.name == item["cashRegisterName"] as! String {
							let fetchRequest: NSFetchRequest<Store> = Store.fetchRequest()
							fetchRequest.fetchLimit = 1
							let objects = try! context.fetch(fetchRequest)
							let store = objects.count == 0 ? Store(context: context) : objects.first!
							store.setJSONValues(json: item["store"] as! NSDictionary)
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
		
		makeHTTPGetRequest(url: "/api/syncronize/causal/\(date)", onCompletion: { data, error in
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

	func syncCustomers(context: NSManagedObjectContext) {
		let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 0
		
		makeHTTPGetRequest(url: "/api/syncronize/customer/\(date)", onCompletion: { data, error in
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

	func syncProducts(context: NSManagedObjectContext) {
		let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
		let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
		fetchRequest.sortDescriptors = [idDescriptor]
		fetchRequest.fetchLimit = 1
		let results = try! context.fetch(fetchRequest)
		let date = results.count == 1 ? results.first!.updatedAt : 0
		
		makeHTTPGetRequest(url: "/api/syncronize/product/\(date)", onCompletion: { data, error in
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
						context.insert(product)
						
						for category in item["categories"] as! [NSDictionary] {
							let productCategory = ProductCategory(context: context)
							productCategory.setJSONValues(json: category)
							context.insert(productCategory)
						}
						
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

			makeHTTPPostRequest(url: "api/syncronize/movement", body: item.getJSONValues(rows: rows), onCompletion:  { data, error in
				if error != nil {
					print(error!.localizedDescription)
				} else {
					do {
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
