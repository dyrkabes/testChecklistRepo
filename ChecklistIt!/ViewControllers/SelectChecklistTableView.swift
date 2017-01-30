////
////  selectChecklistTableView.swift
////  ChecklistIt!
////
////  Created by Anastasia Stepanova-Kolupakhina on 22.12.16.
////  Copyright © 2016 Pavel Stepanov. All rights reserved.
////
//
//import UIKit
//
//
//class SelectChecklistTableView: UITableView {
//	var checklists: [Checklist] = []
//	var filteredChecklists: [Checklist] = []
//	var blurEffectView: UIView!
//	weak var parentViewController: MapViewController?
//	
//	override init(frame: CGRect, style: UITableViewStyle) {
//		super.init(frame: frame, style: style)
//		dataSource = self
//		delegate = self
//	}
//	
//	required init?(coder aDecoder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//	
//	func renewChecklists(checklists: [Checklist], filteredChecklists: [Checklist]) {
//		self.checklists = checklists
//		self.filteredChecklists = filteredChecklists
//	}
//	
//	func show(parentViewController: MapViewController) {
//		self.parentViewController = parentViewController
//		let parentView = parentViewController.view
//		parentView.addSubview(self)
//		
//		self.layer.cornerRadius = 16
//		
//		self.snp_makeConstraints {
//			(make) -> Void in
//			make.width.equalTo(parentView.snp_width).dividedBy(1.3)
//			make.height.equalTo(parentView.snp_height).dividedBy(2)
//			make.centerX.equalTo(parentView.snp_centerX)
//			make.centerY.equalTo(parentView.snp_centerY)
//		}
//		
//		createBlur(parentView)
//		
//	}
//	
//	func createBlur(parentView: UIView) {
//		let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//		blurEffectView = UIVisualEffectView(effect: blurEffect)
//		blurEffectView.frame = parentView.bounds
//		blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//		parentView.addSubview(blurEffectView)
//		
//		parentView.bringSubviewToFront(self)
//		self.reloadData()
//		
//		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SelectChecklistTableView.hideTableViewSelector(_:)))
//		blurEffectView.addGestureRecognizer(gestureRecognizer)
//	}
//
//	// Hides talbe view, removes blur
//	func hideTableViewSelector(gestureRecognizer: UITapGestureRecognizer) {
//		self.removeFromSuperview()
//		blurEffectView.removeFromSuperview()
//		parentViewController?.updateFiltered(filteredChecklists)
//		parentViewController?.placeMarkers()
//	}
//}
//
//
//// MARK: --- TableViewDataSource
//extension SelectChecklistTableView: UITableViewDataSource {
//	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return checklists.count
//	}
//	
//	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//		let tbc = UITableViewCell()
//		tbc.textLabel?.text = checklists[indexPath.row].name
//		if filteredChecklists.contains(checklists[indexPath.row]) {
//			tbc.backgroundColor = UIColor.blueColor()
//		}
//		return tbc
//	}
//}
//
//extension SelectChecklistTableView: UITableViewDelegate {
//	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//		if filteredChecklists.contains(checklists[indexPath.row]) {
//			let cell = tableView.cellForRowAtIndexPath(indexPath)
//			cell?.backgroundColor = UIColor.clearColor()
//			filteredChecklists.removeAtIndex(filteredChecklists.indexOf(checklists[indexPath.row])!)
//		} else {
//			filteredChecklists.append(checklists[indexPath.row])
//			let cell = tableView.cellForRowAtIndexPath(indexPath)
//			cell?.backgroundColor = UIColor.blueColor()
//			cell?.tintColor = UIColor.blueColor()
//		}
//	}
//}
