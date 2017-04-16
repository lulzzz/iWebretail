//
//  AddMovementViewController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 14/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

	@IBOutlet weak var dateTextField: UITextField!
	@IBOutlet weak var numberTextField: UITextField!
	
	var movement: Movement
	let dateFormatter: DateFormatter
	
	@IBAction func textFieldEditing(_ sender: UITextField) {
		
		let datePickerView:UIDatePicker = UIDatePicker()
		datePickerView.datePickerMode = UIDatePickerMode.date
		sender.inputView = datePickerView
		datePickerView.addTarget(self, action: #selector(RegisterViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
	}
	
	@IBAction func buttonSave(_ sender: UIBarButtonItem) {
		do {
			self.movement.movementNumber = Int32(self.numberTextField.text!)!
			self.movement.movementDate = self.dateFormatter.date(from: self.dateTextField.text!)! as NSDate			
			try repository.update(id: self.movement.movementId, item: self.movement)
		} catch {
			let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
		
		navigationController?.popToRootViewController(animated: true)
	}
	
	private let repository: MovementProtocol
	
	required init?(coder aDecoder: NSCoder) {
		self.dateFormatter = DateFormatter()
		self.movement = Movement()
		let delegate = UIApplication.shared.delegate as! AppDelegate
		repository = delegate.ioCContainer.resolve() as MovementProtocol
		
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
        super.viewDidLoad()

        //dateFormatter.dateFormat = "dd-mm-yyyy"
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		
		numberTextField.text = String(self.movement.movementNumber)
		dateTextField.text = dateFormatter.string(for: self.movement.movementDate)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	func datePickerValueChanged(sender:UIDatePicker) {		
		dateTextField.text = dateFormatter.string(for: sender.date)
	}
}
