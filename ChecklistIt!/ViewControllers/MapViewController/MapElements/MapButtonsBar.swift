//
//  MapButtonsBar.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 22.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit
import RxGesture

// Well it is not bar tbh :D

// TODO: Buttons pushes animate at least bit. For instance reduce shadow with animation etc. But it is not that important ofc
class MapButtonsBar: NSObject {
	var buttons: [MapButton]
	
	weak var parentView: UIView!
	weak var parentViewController: MapViewController!
	
	
	// CONST remove from here
	let width = 88
	let height = 44
	let initialTopGap = 18
	let gap = 2
	
	init(parentViewController: MapViewController) {
        
		self.parentViewController = parentViewController
		self.parentView = parentViewController.view
		
		buttons = []
        
        super.init()
        
		for type in MapButtonType.getAllTypes() {
			createButtonWithType(type)
		}
	}

	func createButtonWithType(_ type: MapButtonType) {
		let button = MapButton(frame: CGRect.zero, type: type)
		buttons.append(button)
		
		button.backgroundColor = ResourceManager.getColor(.navBarColor)
		

		parentView.addSubview(button)
		
		createConstraintsAndTitles(button, withType: type)
		DesignConfigurator.createShadow(button, withSize: .small)
		DesignConfigurator.roundCorners(button, value: 8)
		
		button.setTitleColor(ResourceManager.getColor(.secondaryColor),
		                     for: .highlighted)

		
	}
	
	func createConstraintsAndTitles(_ button: UIButton, withType type: MapButtonType) {
		let left: Int
		let top: Int
		let title: String
		
		switch type {
		case .showAll:
			left = gap
			top = initialTopGap
		    title = "Show All"
			
			// sokratit'?
			button.addTarget(self.parentViewController, action: #selector(MapViewController.showAllMarkers), for: .touchDown)
			
		case .filter:
			left = gap
			top = height + gap + initialTopGap
			title = "Filter"
			
			button.addTarget(self.parentViewController, action: #selector(MapViewController.showFilter), for: .touchDown)
		case .hideDone:
			left = width + gap * 2
			top = initialTopGap
			title = "Hide Done"
			
			button.addTarget(self.parentViewController, action: #selector(MapViewController.toggleHideDone), for: .touchDown)
			

		}
		button.setTitle(title, for: UIControlState())
		
		button.snp.makeConstraints {
			(make) -> Void in
			make.left.equalTo(parentView.snp.left).offset(left)
			make.width.equalTo(width)
			make.height.equalTo(height)
			make.top.equalTo(parentView.snp.top).offset(top)
		}
        
        //test part
        
        button.rx.tap.subscribe(onNext: {
            self.animateTap(button: button)
        })
        
        button.addTarget(self, action: #selector(MapButtonsBar.scaleButonOnTapDown(button:)), for: .touchDown)
	}
	
	func bringToFront() {
		for button in buttons {
			parentView.bringSubview(toFront: button)
		}
	}
    
    func scaleButonOnTapDown(button: UIButton) {
        button.layer.setAffineTransform(CGAffineTransform(scaleX: 0.9, y: 0.9))
    }
    
    func animateTap(button: UIButton) {
        let tapAnimation = CABasicAnimation(keyPath: "transform.scale")
        tapAnimation.fromValue = 0.9
        tapAnimation.toValue = 1
        tapAnimation.duration = 0.2
        
        button.layer.add(tapAnimation, forKey: nil)
        button.layer.setAffineTransform(CGAffineTransform(scaleX: 1, y: 1))
//        button.layer.transform.
//        button.transform.scaledBy(x: <#T##CGFloat#>, y: <#T##CGFloat#>)
    }
	
}

class MapButton: UIButton {
	let type: MapButtonType
	
	init(frame: CGRect, type: MapButtonType) {
		self.type = type
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}


enum MapButtonType {
	case showAll
	case filter
	case hideDone
	
	static func getAllTypes() -> [MapButtonType] {
		return [MapButtonType.showAll,
				MapButtonType.filter,
				MapButtonType.hideDone]
	}
}



