//
//  Syncronizer.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 17/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import Foundation

typealias ServiceResponse = (Data, Error?) -> Void

class Syncronizer {
	
	static let shared = Syncronizer()
	
	let baseURL = "http://ec2-35-157-208-60.eu-central-1.compute.amazonaws.com/"
	
	// MARK: - webapi
	
	func makeHTTPGetRequest(url: String, onCompletion: @escaping ServiceResponse) {
		let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, response, error -> Void in
			onCompletion(data!, error)
		})
		task.resume()
	}
	
	func makeHTTPPostRequest(path: String, body: [String: AnyObject], onCompletion: @escaping ServiceResponse) {
		let url = "\(baseURL)\(path)"
		var request =  URLRequest(url: URL(string: url)!)
		request.httpMethod = "POST"
		do {
			try request.httpBody = JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
		} catch let error as NSError {
			print(error)
		}
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
			//let json:JSON = JSON(data: data!)
			onCompletion(data!, error)
		})
		task.resume()
	}

	func run(date: Date) {
		
		
	}
}
