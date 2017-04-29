//
//  CustomerController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 25/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class CustomerController: UIViewController {

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
	
	override func viewDidAppear(_ animated: Bool) {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}

	override func viewWillDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self,name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}

	// MARK: - keyboard
	
	func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			let h = self.view.frame.height - keyboardSize.height
			let offset = getOffset() + 152
			self.view.frame.origin.y = offset > h ? h - offset : 0
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		self.view.frame.origin.y = 0
	}

	func getOffset() -> CGFloat {
		if nameTextField.isEditing {
			return nameTextField.frame.origin.y
		}
		if emailTextField.isEditing {
			return emailTextField.frame.origin.y
		}
		if phoneTextField.isEditing {
			return phoneTextField.frame.origin.y
		}
		if addressTextField.isEditing {
			return addressTextField.frame.origin.y
		}
		if cityTextField.isEditing {
			return cityTextField.frame.origin.y
		}
		if zipTextField.isEditing {
			return zipTextField.frame.origin.y
		}
		if countryTextField.isEditing {
			return countryTextField.frame.origin.y
		}
		if fiscalcodeTextField.isEditing {
			return fiscalcodeTextField.frame.origin.y
		}
		return vatnumberTextField.frame.origin.y
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
