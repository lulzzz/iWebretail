//
//  ServiceRepository.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 20/05/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import CoreData
import UserNotifications

class ServiceRepository: ServiceProtocol {
	
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
	
	lazy var persistentContainer: NSPersistentContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		let container = NSPersistentContainer(name: "Model")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error)")
			}
		})
		return container
	}()
	
	var context: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
	func saveContext () {
		do {
			if persistentContainer.viewContext.hasChanges {
				try persistentContainer.viewContext.save()
			}
		} catch {
			let nserror = error as NSError
			//fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			self.push(title: nserror.localizedDescription, message: nserror.userInfo.description)
		}
	}
}
