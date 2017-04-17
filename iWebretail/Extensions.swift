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
		
		let progressView = UIProgressView(progressViewStyle: .bar)
		progressView.tag = kProgressViewTag
		self.view.addSubview(progressView)
		let navBar = self.navigationBar
		
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[navBar]-0-[progressView]", options: .directionLeadingToTrailing, metrics: nil, views: ["progressView" : progressView, "navBar" : navBar]))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[progressView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["progressView" : progressView]))
		
		progressView.translatesAutoresizingMaskIntoConstraints = false
		progressView.setProgress(0.0, animated: false)
		
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
