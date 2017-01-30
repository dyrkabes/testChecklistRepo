//
//  SwitchLocationCell.swift
//  ChecklistIt!
//
//  Created by Anastasia Stepanova-Kolupakhina on 17.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit

class SwitchLocationCell: UITableViewCell {

	@IBOutlet weak var switchCellLabel: UILabel!
	@IBOutlet weak var showOnMapSwitch: UISwitch!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func configureCell() {
		
	}

}
