//
//  ArticleViewCell.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 16/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit

class ArticleViewCell: UITableViewCell {

	@IBOutlet weak var labelBarcode: UILabel!
	
	@IBOutlet weak var labelName: UILabel!
	
	@IBOutlet weak var textPrice: UITextField!
	
	@IBOutlet weak var textQuantity: UITextField!
	
	@IBOutlet weak var textAmount: UITextField!
	
	@IBAction func updateQuantity(_ sender: UIStepper) {
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
