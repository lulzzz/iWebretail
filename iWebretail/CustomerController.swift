//
//  CustomerController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 25/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class CustomerController: UITableViewController {

	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var phoneTextField: UITextField!
	@IBOutlet weak var addressTextField: UITextField!
	@IBOutlet weak var cityTextField: UITextField!
	@IBOutlet weak var zipTextField: UITextField!
	@IBOutlet weak var countryTextField: UITextField!
	@IBOutlet weak var fiscalcodeTextField: UITextField!
	@IBOutlet weak var vatnumberTextField: UITextField!
	
	public var customer: Customer!
	private let repository: CustomerProtocol
	
	required init?(coder aDecoder: NSCoder) {
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as CustomerProtocol
		
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		
		if customer != nil {
			nameTextField.text = customer.customerName
			emailTextField.text = customer.customerEmail
			phoneTextField.text = customer.customerPhone
			addressTextField.text = customer.customerAddress
			cityTextField.text = customer.customerCity
			zipTextField.text = customer.customerZip
			countryTextField.text = customer.customerCountry
			fiscalcodeTextField.text = customer.customerFiscalCode
			vatnumberTextField.text = customer.customerVatNumber
		}
    }
	
	@IBAction func saveButton(_ sender: UIBarButtonItem) {
		do {
			if customer == nil {
				customer = try repository.add()
			}
			customer.customerName = nameTextField.text
			customer.customerEmail = emailTextField.text
			customer.customerPhone = phoneTextField.text
			customer.customerAddress = addressTextField.text
			customer.customerCity = cityTextField.text
			customer.customerZip = zipTextField.text
			customer.customerCountry = countryTextField.text
			customer.customerFiscalCode = fiscalcodeTextField.text
			customer.customerVatNumber = vatnumberTextField.text
			try repository.update(id: customer.customerId, item: customer)

			self.navigationController?.popViewController(animated: true)
		} catch {
			self.navigationController?.alert(title: "Error", message: "\(error)")
		}
	}
}
