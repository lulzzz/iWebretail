//
//  FirstViewController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 12/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		tableView.delegate = self
		tableView.dataSource = self
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewDidAppear(_ animated: Bool) {
		tableView.reloadData()
	}
	
	// MARK: - Table view data source
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Shared.shared.barcodes.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
		
		let index = (indexPath as NSIndexPath).row
		let item = Shared.shared.barcodes[index]
		
		// Configure the cell...
		cell.textLabel?.text = item
		
		return cell
	}
}

