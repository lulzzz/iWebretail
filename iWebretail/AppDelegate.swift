//
//  AppDelegate.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 12/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

	var window: UIWindow?

	override init() {
		IoCContainer.shared.register { ServiceRepository() as ServiceProtocol }
		IoCContainer.shared.register { MovementRepository() as MovementProtocol }
		IoCContainer.shared.register { MovementArticleRepository() as MovementArticleProtocol }
		IoCContainer.shared.register { CustomerRepository() as CustomerProtocol }

		UIApplication.shared.applicationIconBadgeNumber = 0
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		let navigationBarAppearace = UINavigationBar.appearance()
		//UIApplication.shared.statusBarStyle = .lightContent
		let image = UIImage(named: "background")!
		navigationBarAppearace.setBackgroundImage(image.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)
		navigationBarAppearace.tintColor = .darkText
		navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName: navigationBarAppearace.tintColor]

		UNUserNotificationCenter.current().delegate = self
		UNUserNotificationCenter.current().requestAuthorization(
			options: [.alert,.sound,.badge],
			completionHandler: { (granted,error) in
				if !granted {
					print("Something went wrong")
				} else {
					Synchronizer.shared.iCloudUserIDAsync()
				}
			}
		)
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	// MARK: - Notification

	public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		
		completionHandler([.alert, .sound, .badge])
	}
}

