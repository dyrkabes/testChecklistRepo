//
//  ViewControllerHelper.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 26.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit
import SnapKit

struct ViewControllerHelper {
	static func showFooterOrPlug(_ viewController: HasTableView) -> UIView {
//		let tableView = viewController.getTableView()
		if !ViewControllerHelper.tableViewContainsItems(viewController) {
//			let width = tableView.frame.width
			let plugView = PlugView()
            plugView.spreadIcons()
			
            // move 2 plugView
            let labelBacking = UIView()
            DesignConfigurator.roundCorners(labelBacking, value: 24)

            plugView.addSubview(labelBacking)
            
            let label = UILabel()
			label.text = "No items here yet!"
			label.textColor = ResourceManager.getColor(.navBarColor)
            label.font = UIFont.systemFont(ofSize: 34)
            
//            DesignConfigurator.createShadow(label, withSize: .large)

            
			plugView.addSubview(label)
			label.snp.makeConstraints {
				(make) -> Void in
				make.centerX.equalTo(plugView.snp.centerX)
				make.centerY.equalTo(plugView.snp.centerY)
			}
            
            labelBacking.snp.makeConstraints {
                $0.width.equalTo(label.snp.width)
                $0.height.equalTo(label.snp.height).offset(20)
                $0.center.equalTo(label.snp.center)
            }
            

            let gradientLayer = CAGradientLayer()

            labelBacking.layoutIfNeeded()
//            labelBacking.layoutSubviews()
            gradientLayer.frame = labelBacking.bounds
            gradientLayer.frame.size = CGSize(width: gradientLayer.frame.size.width + 20,
                                              height: gradientLayer.frame.size.height + 20)
//                gradientLayer.frame.size

            
            gradientLayer.colors = [UIColor(white: 1, alpha: 0.1).cgColor, UIColor(white: 1, alpha: 0.95).cgColor, UIColor(white: 1, alpha: 0.1).cgColor]

            
//            gradientLayer.locations = []
            
            gradientLayer.startPoint = CGPoint(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//            labelBacking.layer.addSublayer(gradientLayer)
            
            labelBacking.layer.insertSublayer(gradientLayer, at: 0)
            labelBacking.layoutSubviews()
            
			return plugView
		}
		let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		return footerView
	}
	
	static func getFooterHeight(_ viewController: HasTableView) -> CGFloat {
		let tableViewState = viewController.getTableViewState()
		if tableViewState == .empty {
			return 300
		} else if tableViewState == .hasItems {
			return 44
		} else {
			return 0
		}
	}
	
	fileprivate static func tableViewContainsItems(_ viewController: HasTableView) -> Bool {
		// BAD_EXC_ACCESS for some reason
		// let itemsCount = tableView.numberOfRowsInSection(8)
		
		if viewController.getTableViewState() == .empty {
			return false
		} else {
			return true
		}
	}
}

protocol HasTableView {
	func getTableView() -> UITableView
	
	// I suppose the problem is that it asks footer's height before table view is loaded properly so that gomunculus is needed
	func getTableViewState() -> TableViewState
}

// default implementation for everyone except AllChecklists and Checklists VC
extension HasTableView {
	func getTableViewState() -> TableViewState {
	    return .notDynamic
	}
}

enum TableViewState {
	case empty
	case hasItems
	case notDynamic
}
