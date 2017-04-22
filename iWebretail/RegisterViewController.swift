//
//  RegisterViewController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 14/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

	@IBOutlet weak var numberTextField: UITextField!
	@IBOutlet weak var dateTextField: UITextField!
	@IBOutlet weak var storeTextField: UITextField!
	@IBOutlet weak var causalTextField: UITextField!
	@IBOutlet weak var customerTextField: UITextField!
	@IBOutlet weak var noteTextField: UITextField!
	
	private let repository: MovementProtocol
	
	var movement: Movement
	let store: Store
	let causals: [Causal]
	let customer: Customer? = nil
	
	required init?(coder aDecoder: NSCoder) {
		self.movement = Movement()
		
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as MovementProtocol
		store = try! repository.getStore()
		causals = try! repository.getCausals()
		
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		numberTextField.text = String(self.movement.movementNumber)
		dateTextField.text = self.movement.movementDate?.formatDateInput()
		storeTextField.text = self.store.storeName
		causalTextField.text = causals.first?.causalName
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func dateFieldEditing(_ sender: UITextField) {
		
		let datePickerView:UIDatePicker = UIDatePicker()
		datePickerView.datePickerMode = UIDatePickerMode.date
		sender.inputView = datePickerView
		datePickerView.addTarget(self, action: #selector(RegisterViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
	}
	
	@IBAction func causalFieldEditing(_ sender: UITextField) {
		
		let causalPickerView:UIPickerView = UIPickerView()
		causalPickerView.dataSource = self
		causalPickerView.delegate = self
		sender.inputView = causalPickerView
	}

	@IBAction func buttonSave(_ sender: UIBarButtonItem) {
		do {
			self.movement.movementNumber = Int32(self.numberTextField.text!)!
			self.movement.movementDate = self.dateTextField.text!.toDateInput()
			try repository.update(id: self.movement.movementId, item: self.movement)
		} catch {
			let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
		
		navigationController?.popToRootViewController(animated: true)
	}

	func datePickerValueChanged(sender:UIDatePicker) {
		dateTextField.text = (sender.date as NSDate).formatDateInput()
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
		causalTextField.text = causals[row].causalName
	}
}
