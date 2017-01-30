//
//  ConstrainConfigurator.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 07/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import Foundation
import UIKit

import SnapKit
// Not too usefull too yet
struct ConstrainsConfigurator {
    // if it is sole
    static func constraintsFor(submitButton: UIButton, withViewToRelate relateView: UIView, sole: Bool = false) {
        submitButton.snp.remakeConstraints {
            $0.centerX.equalTo(relateView.snp.centerX)
            $0.width.equalTo(166)
            $0.height.equalTo(44)
        }
        
        if !sole {
            submitButton.snp.makeConstraints{
                $0.bottom.equalTo(relateView.snp.bottom).offset(-20)
            }
        }

        
      
        
        
    }
}
