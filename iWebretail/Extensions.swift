//
//  Extensions.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 17/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

extension UINavigationController {
	func alert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}

extension Int32 {
	static func now() -> Int32 {
		return Int32(Date.timeIntervalSinceReferenceDate)
	}
}

extension Double {
	func formatCurrency() -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.maximumFractionDigits = 2;
		formatter.locale = Locale.current
		let result = formatter.string(from: self as NSNumber);
		
		return result!
	}
}

extension String {
	func toDateInput() -> NSDate {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		return formatter.date(from: self)! as NSDate
	}
	
	func getJSONValues() -> NSDictionary {
		let jsonData = self.data(using: String.Encoding.utf8)
		return try! JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves) as! NSDictionary
	}
}

extension NSDictionary {
	func getJSONString() -> String {
		let jsonData = try! JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
		return String(bytes: jsonData, encoding: String.Encoding.utf8)!
	}
}

extension NSDate {
	func formatDateInput() -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		return formatter.string(from: self as Date)
	}
	
	func formatDateShort() -> String {
		return formatDate(format: "yyyy-MM-dd")
	}
	
	func formatDate(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		return formatter.string(from: self as Date)
	}
}

extension Store {
	func setJSONValues(json: NSDictionary) {
		self.storeId = json["storeId"] as! Int32
		self.storeName = json["storeName"] as? String ?? ""
		self.storeAddress = json["storeAddress"] as? String ?? ""
		self.storeCity = json["storeCity"] as? String ?? ""
		self.storeZip = json["storeZip"] as? String ?? ""
		self.storeCountry = json["storeCountry"] as? String ?? ""
		self.updatedAt = json["updatedAt"] as! Int32
	}
	
	func getJSONValues() -> NSDictionary {
		return [
			"storeId": self.storeId,
			"storeName": self.storeName!,
			"storeAddress":	self.storeAddress!,
			"storeCity": self.storeCity!,
			"storeCountry": self.storeCountry!,
			"storeZip": self.storeZip!,
			"updatedAt": self.updatedAt
		]
	}
}

extension Causal {
	func setJSONValues(json: NSDictionary) {
		self.causalId = json["causalId"] as! Int32
		self.causalName = json["causalName"] as? String ?? ""
		self.causalIsPos = json["causalIsPos"] as? Bool ?? false
		self.causalQuantity = json["causalQuantity"] as! Int32
		self.causalBooked = json["causalBooked"] as! Int32
		self.updatedAt = json["updatedAt"] as! Int32
	}
	
	func getJSONValues() -> NSDictionary {
		return [
			"causalId": self.causalId,
			"causalName": self.causalName!,
			"causalQuantity": self.causalQuantity,
			"causalBooked": self.causalBooked,
			"causalIsPos": self.causalIsPos,
			"updatedAt": self.updatedAt
		]
	}
}

extension Customer {
	func setJSONValues(json: NSDictionary) {
		self.customerId = json["customerId"] as! Int32
		self.customerName = json["customerName"] as? String ?? ""
		self.customerEmail = json["customerEmail"] as? String ?? ""
		self.customerPhone = json["customerPhone"] as? String ?? ""
		self.customerAddress = json["customerAddress"] as? String ?? ""
		self.customerCity = json["customerCity"] as? String ?? ""
		self.customerZip = json["customerZip"] as? String ?? ""
		self.customerCountry = json["customerCountry"] as? String ?? ""
		self.customerFiscalCode = json["customerFiscalCode"] as? String ?? ""
		self.customerVatNumber = json["customerVatNumber"] as? String ?? ""
		self.updatedAt = json["updatedAt"] as! Int32
	}

	func getJSONValues() -> NSDictionary {
		return [
			"customerId": self.customerId,
			"customerName": self.customerName!,
			"customerEmail": self.customerEmail!,
			"customerPhone": self.customerPhone!,
			"customerAddress": self.customerAddress!,
			"customerCity": self.customerCity!,
			"customerZip": self.customerZip!,
			"customerCountry": self.customerCountry!,
			"customerFiscalCode": self.customerFiscalCode!,
			"customerVatNumber": self.customerVatNumber!,
			"updatedAt": self.updatedAt
		]
	}
}

extension Product {
	func setJSONValues(json: NSDictionary) {
		self.productId = json["productId"] as! Int32
		self.productCode = json["productCode"] as? String ?? ""
		self.productName = json["productName"] as? String ?? ""
		self.productUm = json["productUm"] as? String ?? ""
		self.productSelling = json["productSellingPrice"] as! Double
		let discount = json["discount"] as? NSDictionary
		self.productDiscount = discount?["discountPrice"] as? Double ?? 0
		let brand = json["brand"] as! NSDictionary
		self.productBrand = brand["brandName"] as? String ?? ""
		self.updatedAt = json["updatedAt"] as! Int32

		self.productCategories = ""
		for productCategory in json["categories"] as! [NSDictionary] {
			let category = productCategory["category"] as! NSDictionary
			self.productCategories!.append("\(category["categoryName"]!) ")
		}
	}
}

extension ProductArticle {
	func setJSONValues(json: NSDictionary, attributes: [NSDictionary]) {
		self.articleId = json["articleId"] as! Int32
		self.articleBarcode = json["articleBarcode"] as? String ?? ""
		var values = [Int:String]()
		for attribute in attributes {
			for attributeValue in attribute["attributeValues"] as! [NSDictionary] {
				let value = attributeValue["attributeValue"] as! NSDictionary
				values.updateValue(value["attributeValueName"] as! String, forKey: value["attributeValueId"] as! Int)
			}
		}
		self.articleAttributes = ""
		for attributeValue in json["attributeValues"] as! [NSDictionary] {
			let value = values[attributeValue["attributeValueId"] as! Int]
			self.articleAttributes!.append("\(value!) ")
		}
	}
}

extension Movement {
	func getJSONValues(rows: [MovementArticle]) -> NSDictionary {
		var items = [NSDictionary]()
		for row in rows {
			items.append([
				"movementArticleBarcode": row.movementArticleBarcode!,
				"movementArticleQuantity": row.movementArticleQuantity,
				"movementArticlePrice": row.movementArticlePrice
				])
		}
		return [
			"movementNumber": self.movementNumber,
			"movementDate": self.movementDate!.formatDateShort(),
			"movementNote": self.movementNote!,
			"movementStatus": self.movementStatus!,
			"movementUser": self.movementDevice!,
			"movementDevice": self.movementDevice!,
			"movementPayment": self.movementPayment!,
			"movementStore": self.movementStore!.getJSONValues(),
			"movementCausal": self.movementCausal!.getJSONValues(),
			"movementCustomer": self.movementCustomer?.getJSONValues() ?? "",
			"movementItems": items
		]
	}
}

extension Sequence {
	func groupBy<G: Hashable>(closure: (Iterator.Element)->G) -> [G: [Iterator.Element]] {
		var results = [G: Array<Iterator.Element>]()
		forEach {
			let key = closure($0)
			if var array = results[key] {
				array.append($0)
				results[key] = array
			}
			else {
				results[key] = [$0]
			}
		}
		return results
	}
}

