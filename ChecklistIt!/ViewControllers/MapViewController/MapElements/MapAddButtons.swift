//
//  MapAddButtons.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 23.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit


class MapAddButtons {
	let parentViewController: MapViewController
	let addChecklistButton = UIButton()
	let addItemButton = UIButton()
	
	init(parentViewController: MapViewController) {
		self.parentViewController = parentViewController
		configureAddButton(addChecklistButton, type: String(describing: Checklist.self))
		configureAddButton(addItemButton, type: String(describing: Item.self))
	}
	
	func showAddButtons() {
		showAddButton(addChecklistButton, withType: String(describing: Checklist.self))
		showAddButton(addItemButton, withType: String(describing: Item.self))
	}
	
	
	func configureAddButton(_ button: UIButton, type: String) {
		button.setTitle("Add " + type, for: UIControlState())
		button.setTitleColor(UIColor.white, for: UIControlState())
		button.setTitleColor(ResourceManager.getColor(.secondaryColor),
		                     for: .highlighted)
		
		DesignConfigurator.roundCorners(button, value: 8)
		DesignConfigurator.createShadow(button, withSize: .large)
		
		parentViewController.view.addSubview(button)
	}
	
	func showAddButton(_ button: UIButton, withType type: String) {
		parentViewController.view.bringSubview(toFront: button)
		
		var additiveTopCoordinate: Int = 0
		button.backgroundColor = ResourceManager.getColor(.secondaryColor)
		
		if type == String(describing: Checklist.self) {
			additiveTopCoordinate = 60
			button.backgroundColor = ResourceManager.getColor(.navBarColor)
			
			button.addTarget(parentViewController, action: #selector(MapViewController.showAddViewController(_:)), for: .touchDown)
		} else {
			button.addTarget(parentViewController, action: #selector(MapViewController.showChecklistSelector), for: .touchDown)
		}
		
		
		button.snp.remakeConstraints{
			(make) -> Void in
			make.width.equalTo(140)
			make.height.equalTo(44)
			make.bottom.equalTo(parentViewController.view.snp.bottom).offset(20)
			make.centerX.equalTo(parentViewController.view.snp.centerX)
		}
		parentViewController.view.layoutIfNeeded()
		
		UIView.animate(withDuration: 0.8, animations: {
			button.snp.updateConstraints{
				(make) -> Void in
				make.bottom.equalTo(self.parentViewController.view.snp.bottom).offset(-60 - additiveTopCoordinate)
			}
			self.parentViewController.view.layoutIfNeeded()
		}) 
		
	}
	
	func hideAddButtons() {
		UIView.animate(withDuration: 0.8, animations: {
			self.hideAddButton(self.addChecklistButton)
			self.hideAddButton(self.addItemButton)
			self.parentViewController.view.layoutIfNeeded()
		}) 
	}
	
	fileprivate func hideAddButton(_ button: UIButton) {
		button.snp.updateConstraints{
			(make) -> Void in
			make.bottom.equalTo(parentViewController.view.snp.bottom).offset(20)
		}
	}
}
