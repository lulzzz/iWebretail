//
//  Syncronizer.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 17/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

typealias ServiceResponse = (Data?, Error?) -> Void

class Syncronizer {
	
	static let shared = Syncronizer()
	
	let baseURL = "http://ec2-35-157-208-60.eu-central-1.compute.amazonaws.com/"
	var token: String = ""
	
	// MARK: - webapi
	
	func makeHTTPGetRequest(url: String, onCompletion: @escaping ServiceResponse) {
		var request =  URLRequest(url: URL(string: baseURL + url)!)
		request.httpMethod = "GET"
		request.addValue("Bearer token=" + token, forHTTPHeaderField: "Authorization")
		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			data, response, error -> Void in
				onCompletion(data, error)
			})
		task.resume()
	}
	
	func makeHTTPPostRequest(url: String, body: [String: Any], onCompletion: @escaping ServiceResponse) {
		var request =  URLRequest(url: URL(string: baseURL + url)!)
		request.httpMethod = "POST"
		request.addValue("Bearer token=" + token, forHTTPHeaderField: "Authorization")
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
		} catch let error as NSError {
			print(error)
		}
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			data, response, error -> Void in
				//let json:JSON = JSON(data: data!)
				onCompletion(data, error)
			})
		task.resume()
	}

	func run(date: Date) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true

		self.login()
		
//		let totalTaskCount = 100
//		for processedTaskCount in 0...totalTaskCount {
//			let notification = ProgressNotification()
//			notification.total = totalTaskCount
//			notification.current = processedTaskCount
//			DispatchQueue.main.async {
//				NotificationCenter.default.post(name: NSNotification.Name(rawValue: kProgressUpdateNotification), object: notification)
//			}
//		}
		
		makeHTTPGetRequest(url: "api/store", onCompletion: { data, error in
			if error != nil {
				print(error!.localizedDescription)
			} else {
				if let usableData = data {
					do {
						let items = try JSONSerialization.jsonObject(with: usableData, options:.allowFragments) as! [NSDictionary]
						for item in items {
							//let aObject = item as! NSDictionary
							//let store = aObject["storeName"] as! String
							print(item)
						}
					} catch {
						print("Error on sync store: \(error)")
					}
				}
			}
		})
		
		
		self.logout()
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
			} else {
				let json = try! JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
				self.token = json["token"] as! String
			}
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
}
