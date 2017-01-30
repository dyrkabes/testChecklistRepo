//
//  IconCell.swift
//  ChecklistIt!
//
//  Created by Anastasia Stepanova-Kolupakhina on 17.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit

class IconCell: UITableViewCell {

	@IBOutlet weak var iconLabel: UILabel!
	@IBOutlet weak var iconImageView: UIImageView!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
//		self.iconImageView.image = UIImage()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func configureCell() {
		self.iconLabel.text = "Dadada"
		
	}

}
