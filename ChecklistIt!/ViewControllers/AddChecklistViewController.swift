//
//  AddChecklistViewController.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 17.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

//import QuartzCore


class AddChecklistViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	// if editing existing
	var checklistToEdit: Checklist!
	
	var checklist: Checklist!
	var currentCoordinate: CLLocationCoordinate2D?
	
	// why no weak?
	var delegate: ContentChangedDelegate?

	// enum
	var validationIssue: [ValidationError: Bool] = [.emptyName: false,
	                                       .emptyMap: false]
	
	@IBAction func cancel() {
		ManagedObjectContext.managedObjectContext.rollback()
		// hiding before dismissing looks better
		hideKeyboard()
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func toggleLocationSwitch() {
		checklist.showOnMap = (checklist.showOnMap == 0 ? 1 : 0)
		if checklist.isAbleToShow() {
			if currentCoordinate == nil {
				currentCoordinate = CLLocationCoordinate2D()
			}
		}
		
		// adding or deleting a new row
		tableView.beginUpdates()
		let indexPaths = [IndexPath(row: 1, section: 2)]
		if checklist.showOnMap != 0 {
			tableView.insertRows(at: indexPaths, with: .fade)
		} else {
			tableView.deleteRows(at: indexPaths, with: .fade)
		}
		hideKeyboard()
		tableView.endUpdates()
	}
	
	@IBAction func done() {
		//rakovato
		let textFieldCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))! as! DescriptionCell
		
		guard Validator.notEmptyTextField(textFieldCell.descriptionTextField) else {
			    validationIssue[.emptyName] = true
				InfoMessageHelper.createInfoMessageWithText("Please fill the name", andStyle: .error)
			    return
		}
		
		
		guard Validator.isMarker(tableView.cellForRow(at: IndexPath(row: 1, section: 2))) else {
			validationIssue[.emptyMap] = true
			InfoMessageHelper.createInfoMessageWithText("Please mark the place", andStyle: .error)
			return
		}
		
		
		
		if checklist.isAbleToShow() {
			let location: Location = ManagedObjectContext.insertEntity(Location.self) as! Location
			location.latitude = currentCoordinate!.latitude as NSNumber
			location.longitude = currentCoordinate!.longitude as NSNumber
			checklist.location = location
		}
		checklist.changeDate = Date().timeIntervalSince1970 as NSNumber
		
		DefaultsHelper.addChecklist()
		ManagedObjectContext.save()
		
		let functor = Functor(function: NetworkHelper.addBaseItem)
		functor.processRequestWithRequiredLoginWithManagedObject(checklist)
		
		
		
//		 TODO: v principe mojno c/l peredavat' so vsm info, chtob ne tyagat'
		if let _ = delegate {
			delegate!.contentChanged()
		}
		
		if checklist.showOnMap != 0 {
		    let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: IndexPath(row: 1, section: 2)) as? MapCell
			cell!.deinitMapView()
		}
		hideKeyboard()
        dismiss(animated: true) {
            self.delegate?.addAnimation(category: self.checklist.category, itemID: self.checklist.id)
        }
        
        
	}
	
	@IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
		let controller = segue.source as! CategoryPickerViewController
		let categoryCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! IconCell
		// changing image in AddCheckListVC
	    categoryCell.iconImageView.image = ResourceManager.getImageWithCategory(controller.selectedCategoryName)
		categoryCell.iconLabel.text = controller.selectedCategoryName
		checklist.category = controller.selectedCategoryName
		// changing image in the map cell
		if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 2)) as? MapCell {
			cell.setNewCategoryIcon(category: checklist.category, type: checklist.getType())
		}

	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if checklistToEdit == nil {
			// setter needed
			
			checklist = ManagedObjectContext.insertEntity(Checklist.self) as! Checklist
			checklist.id = UUID().uuidString
			
			checklist.username = DefaultsHelper.getUsername()
			
			
			
			checklist.name = ""
			checklist.showOnMap = false
			checklist.itemsDone = 0
			checklist.itemsOverall = 0
			checklist.category = "No category"
			checklist.creationDate = Date().timeIntervalSince1970 as NSNumber
			checklist.location = nil
			checklist.status = "normal"

		} else {
			checklist = checklistToEdit
			
			if checklist.isAbleToShow() {
				if currentCoordinate == nil {
					currentCoordinate = CLLocationCoordinate2D()
				}
			}
		}
		
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddChecklistViewController.hideKeyboardSelector(_:)))
		gestureRecognizer.cancelsTouchesInView = false
		tableView.addGestureRecognizer(gestureRecognizer)
		ColorConfigurator.configureViewController(self)

		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		AppDelegate.networkStatusIcon.show(self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "PickCategory" {
			let categoryPicker = segue.destination as! CategoryPickerViewController
			// letting categoryPicker know what currently selected category is
			categoryPicker.selectedCategoryName = checklist.category
		}
	}
	
	func hideKeyboardSelector(_ gestureRecognizer: UIGestureRecognizer) {
		let point = gestureRecognizer.location(in: tableView)
		let indexPath = tableView.indexPathForRow(at: point)
		// if the tap was not on the cell with the textField
		guard indexPath == nil || indexPath!.section != 0 || indexPath!.row != 0 else {
			return
		}
		hideKeyboard()
	}
	
	func hideKeyboard() {
		let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DescriptionCell
		firstCell.descriptionTextField.resignFirstResponder()
	}
	
	
}



extension AddChecklistViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		switch section {
		case 0:
			return 1
		case 1:
			return 1
		case 2:
			if checklist.showOnMap != 0 {
				return 2
			} else {
				return 1
			}
		default:
			return 0
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
			return "Error"
		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		switch (indexPath.section, indexPath.row) {
		case (0, _):
            // If scrolled the way that is out of window: 
            // [Assert] no index path for table cell being reused
			let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! DescriptionCell
			cell.descriptionTextField.text = checklist.name
			
			cell.descriptionTextField.becomeFirstResponder()
			cell.descriptionTextField.delegate = self
			
			ColorConfigurator.configureDescriptionCell(cell)
			return cell
            
		case (1, 0):
			let cell = tableView.dequeueReusableCell(withIdentifier: "IconCell", for: indexPath) as! IconCell
			cell.iconImageView?.image = ResourceManager.getImageWithCategory(checklist.category)
			cell.iconLabel.text = checklist.category
			ColorConfigurator.configureIconCell(cell)
			return cell
			
		case (2, 0):
			let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchLocationCell", for: indexPath) as! SwitchLocationCell
            cell.showOnMapSwitch.isOn = (checklist.showOnMap != 0)
			ColorConfigurator.configureSwitchCell(cell)
			return cell
			
		case (2, 1):
			let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath) as! MapCell
			let category: String = checklist.category
			if checklistToEdit != nil {
				if checklistToEdit.location != nil {
					cell.addMarkerWithBaseItem(baseItem: checklistToEdit!)
				}
				
			}
			cell.icon = ResourceManager.getFilteredImageForMapWithCategory(category, type: "Checklist")
			
			cell.delegate = self
			return cell
			
		default:
			let cell = UITableViewCell(style: .default, reuseIdentifier: "AddChecklistParameters")
			cell.textLabel!.text = "Something has gone wrong ^^"
			return cell
		}

	}

	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 && indexPath.row == 0 {
			let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DescriptionCell
			firstCell.descriptionTextField.becomeFirstResponder()
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch (indexPath.section, indexPath.row) {
		case (2, 1):
			// TODO: No const
			return 264
		default:
			return 44
		}
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return ViewControllerHelper.showFooterOrPlug(self)
	}
    
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return ViewControllerHelper.getFooterHeight(self)
        // For add VCs some anti code duplication func
        if section == 2 {
            return 44
        }
        return 0
	}
}


extension AddChecklistViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		ColorConfigurator.configureSections(view)
	}
	
}

extension AddChecklistViewController: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let oldText: NSString = textField.text! as NSString
		let newText: NSString = oldText.replacingCharacters(in: range, with: string) as NSString
		checklist.name = newText as String
		
		if validationIssue[.emptyName]! {
			// TODO: With animation
			let textField = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DescriptionCell).descriptionTextField
			
				textField?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
			validationIssue[.emptyName] = false
			
		}
		
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

}

extension AddChecklistViewController: MapCellDelegate {
	func markerChangedPosition(markerToChange marker: GMSMarker) {
		currentCoordinate?.latitude = marker.position.latitude
		currentCoordinate?.longitude = marker.position.longitude
		
		if validationIssue[.emptyMap]! {
			// TODO: With animation
			validationIssue[.emptyMap] = false
			
		}
	}
}

protocol ContentChangedDelegate {
	func contentChanged()
    func addAnimation(category: String, itemID: String)
}

extension ContentChangedDelegate {
    func addAnimation(category: String, itemID: String) {
        //
    }
}

extension AddChecklistViewController: HasTableView {
	func getTableView() -> UITableView {
		return tableView
	}
}


