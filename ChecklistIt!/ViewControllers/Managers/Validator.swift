//
//  Validator.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 08.11.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
import UIKit

class Validator {
	static func notEmptyTextField(_ textField: UITextField) -> Bool {
		if textField.text == "" {
			textField.layer.borderColor = ResourceManager.getCGColor(.warningBGColor)
			textField.layer.borderWidth = 1.0
			return false
		}
		return true
	}
	
	static func isMarker(_ cell: UITableViewCell?) -> Bool {
		if let cell = cell as? MapCell {
			print("Cell is")
			if cell.markerToChange != nil {
				return true
			}
			return false
		} else {
			// no cell - no problem
			return true
		}
	}

}
