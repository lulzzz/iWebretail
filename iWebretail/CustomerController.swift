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
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
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
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
