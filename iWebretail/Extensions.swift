//
//  Extensions.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 17/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

let kProgressViewTag = 10000
let kProgressUpdateNotification = "kProgressUpdateNotification"

extension UINavigationController {
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		
		/*
		let progressView = UIProgressView(progressViewStyle: .bar)
		progressView.tag = kProgressViewTag
		self.view.addSubview(progressView)
		let navBar = self.navigationBar
		
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[navBar]-0-[progressView]", options: .directionLeadingToTrailing, metrics: nil, views: ["progressView" : progressView, "navBar" : navBar]))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[progressView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["progressView" : progressView]))
		
		progressView.translatesAutoresizingMaskIntoConstraints = false
		progressView.setProgress(0.0, animated: false)
		*/
		
		NotificationCenter.default.addObserver(self, selector: #selector(UINavigationController.didReceiveNotification(notification:)), name: NSNotification.Name(rawValue: kProgressUpdateNotification), object: nil)
	}
	
	var progressView : UIProgressView? {
		return self.view.viewWithTag(kProgressViewTag) as? UIProgressView
	}
	
	func didReceiveNotification(notification:NSNotification) {
		if let progress = notification.object as? ProgressNotification {
			if progress.current == progress.total {
				self.progressView?.setProgress(0.0, animated: false)
			} else {
				let perc = Float(progress.current) / Float(progress.total)
				self.progressView?.setProgress(perc, animated: true)
			}
		}
	}
}

class ProgressNotification {
	var current: Int = 0
	var total:   Int = 0
}

extension Store {
	func setJSONValues(json: NSDictionary) {
		self.storeId = json["storeId"] as! Int16
		self.storeName = json["storeName"] as? String ?? ""
		self.storeAddress = json["storeAddress"] as? String ?? ""
		self.storeCity = json["storeCity"] as? String ?? ""
		self.storeZip = json["storeZip"] as? String ?? ""
		self.storeCountry = json["storeCountry"] as? String ?? ""
		self.updatedAt = json["updatedAt"] as! Int64
	}
}

extension Causal {
	func setJSONValues(json: NSDictionary) {
		self.causalId = json["causalId"] as! Int16
		self.causalName = json["causalName"] as? String ?? ""
		self.causalIsPos = json["causalIsPos"] as? Bool ?? false
		self.causalQuantity = json["causalQuantity"] as! Int16
		self.causalBooked = json["causalBooked"] as! Int16
		self.updatedAt = json["updatedAt"] as! Int64
	}
}

extension Customer {
	func setJSONValues(json: NSDictionary) {
		self.customerId = json["customerId"] as! Int64
		self.customerName = json["customerName"] as? String ?? ""
		self.customerEmail = json["customerEmail"] as? String ?? ""
		self.customerPhone = json["customerPhone"] as? String ?? ""
		self.customerAddress = json["customerAddress"] as? String ?? ""
		self.customerCity = json["customerCity"] as? String ?? ""
		self.customerZip = json["customerZip"] as? String ?? ""
		self.customerCountry = json["customerCountry"] as? String ?? ""
		self.customerFiscalCode = json["customerFiscalCode"] as? String ?? ""
		self.customerVatNumber = json["customerVatNumber"] as? String ?? ""
		self.updatedAt = json["updatedAt"] as! Int64
	}
}

extension Product {
	func setJSONValues(json: NSDictionary) {
		self.productId = json["productId"] as! Int64
		self.productCode = json["productCode"] as? String ?? ""
		self.productName = json["productName"] as? String ?? ""
		self.productUm = json["productUm"] as? String ?? ""
		self.productSelling = json["productSelling"] as! Double
		let discount = json["discount"] as? NSDictionary
		self.productDiscount = discount?["discountPrice"] as! Double
		let brand = json["brand"] as! NSDictionary
		self.productBrand = brand["brandName"] as? String ?? ""
		self.updatedAt = json["updatedAt"] as! Int64
	}
}

extension ProductCategory {
	func setJSONValues(json: NSDictionary) {
		self.productId = json["productId"] as! Int64
		let category = json["category"] as! NSDictionary
		self.category = category["categoryName"] as? String ?? ""
	}
}

extension ProductArticle {
	func setJSONValues(json: NSDictionary) {
		self.productId = json["productId"] as! Int64
		self.articleBarcode = json["articleBarcode"] as? String ?? ""
		let attributes = json["attributes"] as! [NSDictionary]
		for attribute in attributes {
			self.articleAttribute?.append(attribute["attributeValue"] as? String ?? "")
		}
	}
}
