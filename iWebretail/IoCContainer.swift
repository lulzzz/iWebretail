//
//  IoCContainer.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 16/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import Foundation

class IoCContainer {
	
	var factories = [String: Any]()
	
	func register<T>(factory: @escaping () -> T) {
		let key = String(describing: T.self)
		factories[key] = factory
	}
	
	func resolve<T>() -> T {
		let key = String(describing: T.self)
		if let factory = factories[key] as? () -> T {
			return factory()
		} else {
			fatalError("Registration not found")
		}
	}
}
