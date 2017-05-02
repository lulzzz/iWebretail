//
//  RegisterViewController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 14/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class RegisterController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var numberTextField: UITextField!
	@IBOutlet weak var dateTextField: UITextField!
	@IBOutlet weak var storeTextField: UITextField!
	@IBOutlet weak var causalTextField: UITextField!
	@IBOutlet weak var customerButton: UIButton!
	@IBOutlet weak var noteTextView: UITextView!
	
	var store: Store?
	var causals: [Causal]
	var customer: Customer? = nil
	private let repository: MovementProtocol
	
	required init?(coder aDecoder: NSCoder) {
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as MovementProtocol

		store = try! repository.getStore()
		causals = try! repository.getCausals()

		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let movement = Synchronizer.shared.movement!
		
		if movement.completed {
			self.navigationItem.rightBarButtonItem?.isEnabled = false
		}
		
		amountLabel.text = movement.movementAmount.formatCurrency()
		numberTextField.text = String(movement.movementNumber)
		dateTextField.text = movement.movementDate?.formatDateInput()
		noteTextView.text = movement.movementNote
		customerButton.layer.borderColor = UIColor.lightGray.cgColor
		customerButton.layer.borderWidth = 0.25
		customerButton.layer.cornerRadius = 5
		noteTextView.layer.borderColor = UIColor.lightGray.cgColor
		noteTextView.layer.borderWidth = 0.25
		noteTextView.layer.cornerRadius = 5
		
		if movement.movementStore != nil {
			storeTextField.text = movement.movementStore!.getJSONValues()["storeName"] as? String
		} else if store == nil {
			self.navigationController?.alert(title: "Attention", message: "Register your device: \(UIDevice.current.name)")
		} else {
			storeTextField.text = store!.storeName
			movement.movementStore = store!.getJSONValues().getJSONString()
		}
		
		if movement.movementCausal != nil {
			causalTextField.text = movement.movementCausal!.getJSONValues()["causalName"] as? String
		} else {
			causalTextField.text = causals.first?.causalName
			movement.movementCausal = causals.first?.getJSONValues().getJSONString()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

		let movement = Synchronizer.shared.movement!
		if movement.movementCustomer != nil {
			customerButton.setTitle(movement.movementCustomer!.getJSONValues()["customerName"] as? String, for: .normal)
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self,name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	@IBAction func dateFieldEditing(_ sender: UITextField) {
		let datePickerView = UIDatePicker()
		datePickerView.datePickerMode = UIDatePickerMode.date
		sender.inputView = datePickerView
		datePickerView.addTarget(self, action: #selector(RegisterController.datePickerValueChanged), for: UIControlEvents.valueChanged)
	}
	
	@IBAction func causalFieldEditing(_ sender: UITextField) {
		let causalPickerView = UIPickerView()
		causalPickerView.dataSource = self
		causalPickerView.delegate = self
		sender.inputView = causalPickerView
	}

	@IBAction func buttonSave(_ sender: UIBarButtonItem) {
		do {
			let movement = Synchronizer.shared.movement!

			movement.movementNumber = Int32(numberTextField.text!)!
			movement.movementDate = dateTextField.text!.toDateInput()
			movement.movementNote = noteTextView.text
			movement.movementDevice = UIDevice.current.name
			movement.completed = true
			
			try repository.update(id: movement.movementId, item: movement)
		} catch {
			self.navigationController?.alert(title: "Error", message: "\(error)")
		}
				
		navigationController?.popToRootViewController(animated: true)
	}

	func datePickerValueChanged(sender:UIDatePicker) {
		dateTextField.text = (sender.date as NSDate).formatDateInput()
	}

	// MARK: - keyboard
	
	func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			let h = self.view.frame.height - keyboardSize.height
			let offset = (noteTextView.isFirstResponder ? noteTextView.frame.origin.y + 210 : 0)
			self.view.frame.origin.y = offset > h ? h - offset : 0
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		self.view.frame.origin.y = 0
	}

	//MARK: - Delegates and data sources
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return causals.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return causals[row].causalName
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let movement = Synchronizer.shared.movement!

		if causals[row].causalIsPos {
			numberTextField.text = String(movement.movementNumber)
			numberTextField.isEnabled = true
			movement.movementStatus = "Completed"
		} else {
			numberTextField.text = "0"
			numberTextField.isEnabled = false
			movement.movementStatus = "New"
		}
		movement.movementCausal = causals[row].getJSONValues().getJSONString()
		causalTextField.text = causals[row].causalName
	}
}
