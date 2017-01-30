//
//  AddItemViewController.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 19.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit
import GoogleMaps

class AddItemViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	
	var itemToEdit: Item?
	var currentChecklist: Checklist!
	var item: Item!
	var currentCoordinate: CLLocationCoordinate2D?
	var delegate: ContentChangedDelegate?
	
	var validationIssue: [ValidationError: Bool] = [.emptyName: false,
	                                                .emptyMap: false]
	
//	let infoView = UIView()
	
	@IBAction func cancel() {
		ManagedObjectContext.managedObjectContext.rollback()
        hideKeyboard()
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func done() {
		let textFieldCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))! as! DescriptionCell
		guard Validator.notEmptyTextField(textFieldCell.descriptionTextField) else {
				validationIssue[.emptyName] = true
				InfoMessageHelper.createInfoMessageWithText("Please fill the name", andStyle: .error)
				return
		}
		
		guard Validator.isMarker(tableView.cellForRow(at: IndexPath(row: 1, section: 2))) else {
			validationIssue[.emptyMap] = true
			InfoMessageHelper.createInfoMessageWithText("Please mark the palce", andStyle: .error)
			return
		}
		
		if item.isAbleToShow() {
			let location: Location = ManagedObjectContext.insertEntity(Location.self) as! Location
			location.latitude = currentCoordinate!.latitude as NSNumber
			location.longitude = currentCoordinate!.longitude as NSNumber
			item.location = location
		}
		
		if itemToEdit == nil {
			var itemsOverall = currentChecklist.itemsOverall as Int
			itemsOverall += 1
			currentChecklist.itemsOverall = itemsOverall as NSNumber
		}
		item.changeDate = Date().timeIntervalSince1970 as NSNumber
		
		DefaultsHelper.addItem()
		ManagedObjectContext.save()
		
		let functor = Functor(function: NetworkHelper.addBaseItem)
		functor.processRequestWithRequiredLoginWithManagedObject(item)
		
		if let _ = delegate {
			delegate!.contentChanged()
		}
        hideKeyboard()
        dismiss(animated: true) {
            self.delegate?.addAnimation(category: self.item.category, itemID: self.item.id)
        }
	}
		
	@IBAction func toggleLocationSwitch() {
		item.showOnMap = (item.showOnMap == 0 ? 1 : 0)
		
		if item.isAbleToShow() {
			if currentCoordinate == nil {
				currentCoordinate = CLLocationCoordinate2D()
			}
		}
		
		tableView.beginUpdates()
		let indexPaths = [IndexPath(row: 1, section: 2)]
		if item.showOnMap != 0 {
			tableView.insertRows(at: indexPaths, with: .fade)
		} else {
			tableView.deleteRows(at: indexPaths, with: .fade)
		}
		hideKeyboard()
		tableView.endUpdates()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let _ = itemToEdit {
			item = itemToEdit
            if item.isAbleToShow() {
                if currentCoordinate == nil {
                    currentCoordinate = CLLocationCoordinate2D()
                }
            }
		} else {
			item = ManagedObjectContext.insertEntity(Item.self) as! Item
			item.id = UUID().uuidString
			item.checklist = currentChecklist
			item.username = DefaultsHelper.getUsername()
			item.descriptionText = ""
			item.done = 0
			item.name = ""
			item.showOnMap = false
			item.category = "No category"
			item.creationDate = Date().timeIntervalSince1970 as NSNumber
			item.location = nil
			item.changeDate = Date().timeIntervalSince1970 as NSNumber
			item.status = "normal"
//			let location: Location = ManagedObjectContext.insertEntity(Location) as! Location
//			item.location = location
		}
		
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.hideKeyboardSelector))
		gestureRecognizer.cancelsTouchesInView = false
		tableView.addGestureRecognizer(gestureRecognizer)
		ColorConfigurator.configureViewController(self)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		AppDelegate.networkStatusIcon.show(self)
	}
	
	@IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
		let controller = segue.source as! CategoryPickerViewController
		let categoryCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! IconCell
		categoryCell.imageView?.image = ResourceManager.getImageWithCategory(controller.selectedCategoryName)
		categoryCell.textLabel?.text = controller.selectedCategoryName
		
		item.category = controller.selectedCategoryName
		
		if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 2)) as? MapCell {
			cell.setNewCategoryIcon(category: item.category, type: item.getType())
		}
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let categoryPicker = segue.destination as! CategoryPickerViewController
		// letting categoryPicker know what currently selected category is
		categoryPicker.selectedCategoryName = item.category
	}
	
	func hideKeyboardSelector(_ gestureRecognizer: UIGestureRecognizer) {
		let point = gestureRecognizer.location(in: tableView)
		let indexPath = tableView.indexPathForRow(at: point)
		
		if indexPath != nil && indexPath!.section == 0 {
			return
		}
		hideKeyboard()
	}
	
	func hideKeyboard() {
		var cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DescriptionCell
		if !cell.descriptionTextField.isFirstResponder {
			cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! DescriptionCell
		}
		cell.descriptionTextField.resignFirstResponder()
	}
	
	func nameValueChanged(_ textField: UITextField) {
		item.name = textField.text!
		if validationIssue[.emptyName]! {
			let textField = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DescriptionCell).descriptionTextField
			textField?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
			validationIssue[.emptyName] = false
//			infoView.removeFromSuperview()
		}
	}
	
	func descriptionValueChanged(_ textField: UITextField) {
		item.descriptionText = textField.text!
	}

}

protocol AddItemViewControllerDelegate {
	func contentChanged()
}

extension AddItemViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch (indexPath.section, indexPath.row) {
		case (0, _):
			let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as! DescriptionCell
			cell.descriptionTextField.becomeFirstResponder()
			return
		default:
			return
		}
	}
}

extension AddItemViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			// name and description
			return 2
		case 1:
			// category
			return 1
		case 2:
			// map category
			return item.showOnMap == 0 ? 1 : 2
		default:
			return 0
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch (indexPath.section, indexPath.row) {
		case (0, 0):
			let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! DescriptionCell
			// rakomakafon
			cell.descriptionTextField.addTarget(self, action: #selector(AddItemViewController.nameValueChanged), for: UIControlEvents.allEditingEvents)
			cell.descriptionTextField.text = item.name
			ColorConfigurator.configureDescriptionCell(cell)
			return cell
			
		case (0, 1):
			let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! DescriptionCell
			cell.descriptionTextField.text = item.descriptionText
			//TODO: 2 selectors?
			cell.descriptionTextField.addTarget(self, action: #selector(AddItemViewController.descriptionValueChanged), for: UIControlEvents.allEditingEvents)
			ColorConfigurator.configureDescriptionCell(cell)
			return cell
			
		case (1, _):
			// not a swi here
			let cell = tableView.dequeueReusableCell(withIdentifier: "IconCell", for: indexPath) as! IconCell
			cell.iconLabel?.text = item.category
			cell.iconImageView?.image = ResourceManager.getImageWithCategory(item.category)
			ColorConfigurator.configureIconCell(cell)
			return cell
			
		case (2, 0):
			let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchLocationCell", for: indexPath) as! SwitchLocationCell
			cell.showOnMapSwitch.isOn = (item.showOnMap != 0)
			ColorConfigurator.configureSwitchCell(cell)
			return cell
			
		case (2, 1):
			let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath) as! MapCell
			cell.delegate = self
			let category = item.category
			if itemToEdit != nil {
				if itemToEdit!.location != nil {
					cell.addMarkerWithBaseItem(baseItem: itemToEdit!)
				}
			} else {
				if currentChecklist.isAbleToShow() {
					cell.createChecklistMarker(checklist: currentChecklist)
					cell.moveCameraToChecklistMarker()
				} else {
					cell.defaultCameraPosition()
				}
			}
			
			cell.icon = ResourceManager.getFilteredImageForMapWithCategory(category, type: "Item")
			
			return cell
		default:
			let cell = UITableViewCell(style: .default, reuseIdentifier: "AddChecklistParameters")
			cell.textLabel!.text = "This should not apeear"
			return cell
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "General Info"
		case 1:
			return "Category"
		case 2:
			return "Placement"
		default:
			return "No way this appears"
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 1 && indexPath.section == 2 {
			return 264
		}
		return 44
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return ViewControllerHelper.showFooterOrPlug(self)
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//		return 0
        // For add VCs some anti code duplication func
        if section == 2 {
            return 44
        }
        return 0
	}
}

extension AddItemViewController: MapCellDelegate {
	func markerChangedPosition(markerToChange marker: GMSMarker) {
		currentCoordinate?.latitude = marker.position.latitude
		currentCoordinate?.longitude = marker.position.longitude
		
		if validationIssue[.emptyMap]! {
			validationIssue[.emptyMap] = false
		}
	}
}

extension AddItemViewController: HasTableView {
	func getTableView() -> UITableView {
		return tableView
	}
}
