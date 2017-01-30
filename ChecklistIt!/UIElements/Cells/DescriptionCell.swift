//
//  DescriptionCell.swift
//  ChecklistIt!
//
//  Created by Anastasia Stepanova-Kolupakhina on 17.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
import UIKit

class DescriptionCell: UITableViewCell {
	@IBOutlet weak var descriptionTextField: UITextField!
	
	func configureCell() {
		self.descriptionTextField.text = "JABA"
	}
	
}
