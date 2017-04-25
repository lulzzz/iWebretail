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
	@IBOutlet weak var customerButton: UIButton!
	@IBOutlet weak var noteTextView: UITextView!
	
	private let repository: MovementProtocol
	
	let store: Store
	let causals: [Causal]
	var customer: Customer? = nil
	var movement: Movement!
	
	required init?(coder aDecoder: NSCoder) {
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as MovementProtocol
		store = try! repository.getStore()
		causals = try! repository.getCausals()
		
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
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
		} else {
			storeTextField.text = store.storeName
			movement.movementStore = store.getJSONValues().getJSONString()
		}
		
		if movement.movementCausal != nil {
			causalTextField.text = movement.movementCausal!.getJSONValues()["causalName"] as? String
		} else {
			causalTextField.text = causals.first?.causalName
			movement.movementCausal = causals.first?.getJSONValues().getJSONString()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if movement.movementCustomer != nil {
			customerButton.setTitle(movement.movementCustomer!.getJSONValues()["customerName"] as? String, for: .normal)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func dateFieldEditing(_ sender: UITextField) {
		let datePickerView = UIDatePicker()
		datePickerView.datePickerMode = UIDatePickerMode.date
		sender.inputView = datePickerView
		datePickerView.addTarget(self, action: #selector(RegisterViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
	}
	
	@IBAction func causalFieldEditing(_ sender: UITextField) {
		let causalPickerView = UIPickerView()
		causalPickerView.dataSource = self
		causalPickerView.delegate = self
		sender.inputView = causalPickerView
	}

	@IBAction func buttonSave(_ sender: UIBarButtonItem) {
		do {
			movement.movementNumber = Int32(numberTextField.text!)!
			movement.movementDate = dateTextField.text!.toDateInput()
			movement.movementNote = noteTextView.text
			movement.movementDevice = UIDevice.current.name
			movement.completed = true
			
			try repository.update(id: movement.movementId, item: movement)
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
		if causals[row].causalIsPos {
			numberTextField.text = String(movement.movementNumber)
			numberTextField.isEnabled = true
		} else {
			numberTextField.text = "0"
			numberTextField.isEnabled = false
		}
		movement.movementCausal = causals[row].getJSONValues().getJSONString()
		causalTextField.text = causals[row].causalName
	}

	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let viewController = segue.destination as! CustomerViewController
		viewController.movement = self.movement
	}
}
