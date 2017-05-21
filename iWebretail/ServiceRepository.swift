//
//  ServiceRepository.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 20/05/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ServiceRepository: ServiceProtocol {
	
	let appDelegate: AppDelegate;
	
	init() {
		appDelegate = UIApplication.shared.delegate as! AppDelegate
	}
	
	// MARK: - Notification

	func push(title: String, message: String) {
		let center = UNUserNotificationCenter.current()
		center.getNotificationSettings { (settings) in
			if settings.authorizationStatus == .authorized {
				let content = UNMutableNotificationContent()
				content.title = title
				content.body = message
				content.sound = UNNotificationSound.default()
				content.categoryIdentifier = "message"
				//content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
				let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
				let request = UNNotificationRequest.init(identifier: "iWebretail", content: content, trigger: trigger)
				center.add(request, withCompletionHandler: { (error) in
					if error != nil {
						print(error!.localizedDescription)
					}
				})
			}
		}
	}
	
	// MARK: - Core Data stack
	
	var context: NSManagedObjectContext {
		return appDelegate.persistentContainer.viewContext
	}
	
	func save () {
		appDelegate.saveContext()
	}
}
