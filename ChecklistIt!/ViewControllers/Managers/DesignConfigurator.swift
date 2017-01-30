//
//  DesignConfigurator.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 25.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit

struct DesignConfigurator {
	static func roundCorners(_ view: UIView, value: Int) {
		view.layer.cornerRadius = CGFloat(value)
	}
	
	static func createShadow(_ view: UIView, withSize size: ShadowSize) {
		let shadowOffset: CGSize
		let shadowRadius: CGFloat
		switch size {
		case .small:
			shadowOffset = CGSize(width: 2, height: 2)
			shadowRadius = 4
		case .large:
			shadowOffset = CGSize(width: 4, height: 4)
			shadowRadius = 8
		}
		
		view.layer.shadowOffset = shadowOffset
		view.layer.shadowRadius = shadowRadius
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOpacity = 1.0
	}
	
	static func designPeekingRegisterView(_ view: UIView) {
		DesignConfigurator.roundCorners(view, value: 8)
		view.layer.borderColor = ResourceManager.getCGColor(ColorName.navBarColor)
		view.layer.borderWidth = 2
		
	}
	
	static func createBlurBackgroundForParentView(_ parentView: UIView, andView view: UIView) -> UIVisualEffectView {
		let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		blurEffectView.frame = parentView.bounds
		blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		parentView.addSubview(blurEffectView)
		parentView.bringSubview(toFront: view)
		
		
		return blurEffectView
	}
    
    
    // unify for all button types
    static func configureRegisterLoginButton(submitButton: UIButton) {
        submitButton.layer.cornerRadius = 5
        submitButton.backgroundColor = ResourceManager.getColor(ColorName.secondaryColor)
        submitButton.setTitleColor(UIColor.white, for: UIControlState())
        submitButton.setTitle("Register/Login", for: UIControlState())
        submitButton.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), for: .highlighted)
    }
}

enum ShadowSize {
	case small
	case large
}
