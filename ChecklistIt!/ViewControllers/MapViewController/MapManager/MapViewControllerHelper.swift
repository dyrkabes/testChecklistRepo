//
//  MapViewControllerHelper.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 22.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

//
//  selectChecklistTableView.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 22.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit

// TODO: Adding an item to chls from map  doesnt make AllChls counters refresh 


class MapViewControllerHelper: NSObject {
	var checklists: [Checklist] = []
	var filteredChecklists: [Checklist] = []
	var checklistsAbleToShow: [Checklist] = []
	var blurEffectView = UIView()
	let selectionTableView = UITableView()
	weak var parentViewController: MapViewController?
	
	var type: SelectionTableViewType = .filter
	
	override init() {
		super.init()
		selectionTableView.dataSource = self
		selectionTableView.delegate = self
        
        selectionTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MapTableViewCell")
	}
	
	func setChecklistsForHelper(_ checklists: [Checklist]) {
		self.checklists = checklists
		self.checklistsAbleToShow = checklists.filter { $0.isAbleToShow() }
	}
	
	func showSelectionTableView(_ parentViewController: MapViewController, filter: Bool = true) {
		self.parentViewController = parentViewController
		let parentView = parentViewController.view!
		parentView.addSubview(selectionTableView)
        
        selectionTableView.separatorStyle = .none
		
		DesignConfigurator.roundCorners(selectionTableView, value: 16)
		
		selectionTableView.snp.makeConstraints {
			(make) -> Void in
			make.width.equalTo(parentView.snp.width).dividedBy(1.3)
			make.height.equalTo(parentView.snp.height).dividedBy(2)
			make.centerX.equalTo(parentView.snp.centerX)
			make.centerY.equalTo(parentView.snp.centerY)
		}
		
		type = filter ? .filter : .selection

		blurEffectView = DesignConfigurator.createBlurBackgroundForParentView(parentView, andView: selectionTableView)
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewControllerHelper.hideTableViewSelector(_:)))
		blurEffectView.addGestureRecognizer(gestureRecognizer)
		
		selectionTableView.reloadData()
	}
	
	// Hides talbe view, removes blur
	func hideTableViewSelector(_ gestureRecognizer: UITapGestureRecognizer) {
		selectionTableView.removeFromSuperview()
		blurEffectView.removeFromSuperview()
		parentViewController?.placeMarkers()
	}
}

enum SelectionTableViewType: Int {
	case filter
	case selection
}


// MARK: --- TableViewDataSource
extension MapViewControllerHelper: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// decrease count for filter
		if type == .selection {
			return checklists.count
		} else {
			return checklists.filter{ $0.isAbleToShow() }.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var checklistsForTableView = [Checklist]()
		// dont give to filter chls without show
//		let tbc = UITableViewCell()
        
        
        
        let tbc = tableView.dequeueReusableCell(withIdentifier: "MapTableViewCell", for: indexPath)
        
		if type == .filter {
			checklistsForTableView = checklistsAbleToShow
			if filteredChecklists.contains(checklists[indexPath.row]) {
				tbc.backgroundColor = ResourceManager.getColor(.secondaryColor)
            } else {
                tbc.backgroundColor = UIColor.clear
            }
		} else {
			checklistsForTableView = checklists
		}
		tbc.textLabel?.text = (checklistsForTableView[indexPath.row] as Checklist).name
		return tbc
	}
}

extension MapViewControllerHelper: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if type == .filter {
			if filteredChecklists.contains(checklists[indexPath.row]) {
				let cell = tableView.cellForRow(at: indexPath)
				cell?.backgroundColor = UIColor.clear
				filteredChecklists.remove(
					at: filteredChecklists.index(of: checklistsAbleToShow[indexPath.row])!)
			} else {
				filteredChecklists.append(checklistsAbleToShow[indexPath.row])
				let cell = tableView.cellForRow(at: indexPath)
				cell?.backgroundColor = ResourceManager.getColor(.secondaryColor)
			}
		} else {
			parentViewController?.showAddItemViewController(
				checklistsAbleToShow[indexPath.row])
		}
		let cell = tableView.cellForRow(at: indexPath)
		cell?.selectedBackgroundView = UIView()
	}
}

