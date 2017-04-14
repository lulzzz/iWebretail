//
//  AddMovementViewController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 14/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class AddMovementViewController: UIViewController {

	@IBOutlet weak var dateTextField: UITextField!
	@IBOutlet weak var numberTextField: UITextField!
	
	let dateFormatter = DateFormatter()
	
	@IBAction func textFieldEditing(_ sender: UITextField) {
		
		let datePickerView:UIDatePicker = UIDatePicker()
		datePickerView.datePickerMode = UIDatePickerMode.date
		sender.inputView = datePickerView
		datePickerView.addTarget(self, action: #selector(AddMovementViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
	}
	
	@IBAction func buttonSave(_ sender: UIBarButtonItem) {
		let context = Shared.shared.getContext()
		
		let movement = Movement(context: context)
		movement.movementNumber = Int32(self.numberTextField.text!)!
		movement.movementDate = self.dateFormatter.date(from: self.dateTextField.text!)! as NSDate
		
		context.insert(movement)
		do {
			try context.save()
		} catch {
			print("Error on buttonSave: \(error)")
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		//dateFormatter.dateFormat = "dd-mm-yyyy"
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	func datePickerValueChanged(sender:UIDatePicker) {
		
		dateTextField.text = dateFormatter.string(for: sender.date)
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
