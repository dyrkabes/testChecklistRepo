//
//  FeedbackCell.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 20/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class FeedbackCell: UITableViewCell {
    let titleLabel = UILabel()
    let statusLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(titleLabel)
        titleLabel.snp.remakeConstraints {
            $0.left.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(22)
            $0.width.equalTo(128)
        }
        
        addSubview(statusLabel)
        statusLabel.snp.remakeConstraints {
            $0.right.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(22)
            $0.width.equalTo(128)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
