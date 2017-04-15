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
	
	let dateFormatter = DateFormatter()
	
	@IBAction func textFieldEditing(_ sender: UITextField) {
		
		let datePickerView:UIDatePicker = UIDatePicker()
		datePickerView.datePickerMode = UIDatePickerMode.date
		sender.inputView = datePickerView
		datePickerView.addTarget(self, action: #selector(RegisterViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
	}
	
	@IBAction func buttonSave(_ sender: UIBarButtonItem) {
		let context = Shared.shared.getContext()
		
		do {
			Shared.shared.movement.movementNumber = Int32(self.numberTextField.text!)!
			Shared.shared.movement.movementDate = self.dateFormatter.date(from: self.dateTextField.text!)! as NSDate
			
			try context.save()
		} catch {
			let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
		
		navigationController?.popToRootViewController(animated: true)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		//dateFormatter.dateFormat = "dd-mm-yyyy"
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		
		numberTextField.text = String(Shared.shared.movement.movementNumber)
		dateTextField.text = dateFormatter.string(for: Shared.shared.movement.movementDate)
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
