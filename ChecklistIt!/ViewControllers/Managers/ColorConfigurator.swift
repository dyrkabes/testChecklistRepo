//
//  ColorConfigurator.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 08.11.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
import UIKit

class ColorConfigurator {
	static func configureViewController(_ viewController: UIViewController) {
		// nav bar background
		viewController.navigationController?.navigationBar.isTranslucent = false
		viewController.navigationController?.navigationBar.barTintColor = ResourceManager.getColor(.navBarColor)
		
		// nav bar title attribs
		viewController.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ResourceManager.getColor(.barButtonColor)]

		// TabBar
		if viewController is AllChecklistsViewController ||
			viewController is MapViewController || viewController is StatisticsViewController
        || viewController is SettingsViewController || viewController is CreativeViewController {
			ColorConfigurator.configureTapBar(viewController)
		}
		
        viewController.navigationController?.navigationBar.barStyle = UIBarStyle.black


		switch viewController {
			case is AllChecklistsViewController:
				viewController.title = "All Checklists"
				
                // nav bar configuring
                // todo: shift to function
                
                viewController.navigationItem.rightBarButtonItem = ColorConfigurator.configureNavBarButtonWithImageName(imageName: "Add", withViewController: viewController, andAction: #selector(AllChecklistsViewController.addChecklist))
            
            
			case is AddChecklistViewController:
				let addViewController = viewController as! AddChecklistViewController
				if addViewController.checklistToEdit != nil {
					addViewController.title = "Edit Checklist"
				} else {
					addViewController.title = "Add Checklist"
				}
            
                viewController.navigationItem.leftBarButtonItem = ColorConfigurator.configureNavBarButtonWithImageName(imageName: "Back", withViewController: viewController, andAction: #selector(AddChecklistViewController.cancel))
                viewController.navigationItem.rightBarButtonItem = ColorConfigurator.configureNavBarButtonWithImageName(imageName: "Done", withViewController: viewController, andAction: #selector(AddChecklistViewController.done))
			
			case is ChecklistViewController:
				viewController.title = (viewController as! ChecklistViewController).currentChecklist.name
            
                viewController.navigationItem.leftBarButtonItem = ColorConfigurator.configureNavBarButtonWithImageName(imageName: "Back", withViewController: viewController, andAction: #selector(ChecklistViewController.back))
                viewController.navigationItem.rightBarButtonItem = ColorConfigurator.configureNavBarButtonWithImageName(imageName: "Add", withViewController: viewController, andAction: #selector(ChecklistViewController.addItem))
			
			case is AddItemViewController:
				let addViewController = viewController as! AddItemViewController
				if addViewController.itemToEdit != nil {
					addViewController.title = "Edit Item"
				} else {
					addViewController.title = "Add Item"
				}
            
                viewController.navigationItem.leftBarButtonItem = ColorConfigurator.configureNavBarButtonWithImageName(imageName: "Back", withViewController: viewController, andAction: #selector(AddItemViewController.cancel))
                viewController.navigationItem.rightBarButtonItem = ColorConfigurator.configureNavBarButtonWithImageName(imageName: "Done", withViewController: viewController, andAction: #selector(AddItemViewController.done))
			
			case is MapViewController:
                break
//				viewController.navigationController?.navigationBar.barStyle = UIBarStyle.black
			case is CategoryPickerViewController:
				viewController.title = "Pick Category"
                viewController.navigationItem.leftBarButtonItem = ColorConfigurator.configureNavBarButtonWithImageName(imageName: "Back", withViewController: viewController, andAction: #selector(CategoryPickerViewController.cancel))
			
			case is StatisticsViewController:
				viewController.title = "Statistics"
            case is SettingsViewController:
                viewController.title = "Settings"
            case is FeedbackViewController:
                viewController.title = "Feedback"
                viewController.view.backgroundColor = UIColor.white
                viewController.navigationItem.leftBarButtonItem = ColorConfigurator.configureNavBarButtonWithImageName(imageName: "Back", withViewController: viewController, andAction: #selector(FeedbackViewController.back))
            case is CreativeViewController:
                viewController.title = "Creative"
            
			default:
				viewController.title = "Error"
		}
		
	}
	
	private static func configureTapBar(_ viewController: UIViewController) {
		// tab bar background and text color
		viewController.tabBarController?.tabBar.barTintColor = ResourceManager.getColor(.navBarColor)
		viewController.tabBarController?.tabBar.tintColor = ResourceManager.getColor(.barButtonColor)
		for item in (viewController.tabBarController?.tabBar.items!)! {
			let notSelectedItem: NSDictionary = [NSForegroundColorAttributeName: ResourceManager.getColor(.textColor)]
			let selectedItem: NSDictionary = [NSForegroundColorAttributeName: ResourceManager.getColor(.barButtonColor)]
			item.setTitleTextAttributes(notSelectedItem as? [String : AnyObject], for: UIControlState())
			item.setTitleTextAttributes(selectedItem as? [String : AnyObject], for: .selected)
		}
	}
    
    static func configureNavBarButtonWithImageName(imageName: String, withViewController viewController: UIViewController, andAction selector: Selector) -> UIBarButtonItem {
        let navButton = UIButton()
        navButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)

        navButton.tintColor = ResourceManager.getColor(.barButtonColor)
        
        let addImage = UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
        
        navButton.setImage(addImage, for: .normal)
        navButton.addTarget(viewController, action: selector, for: .touchDown)
        
        return UIBarButtonItem(customView: navButton)
    }
	
	
// MARK: -- Cell configuring
	
	static func configureSwitchCell(_ cell: SwitchLocationCell) {
		cell.showOnMapSwitch.tintColor = ResourceManager.getColor(.navBarColor)
		cell.showOnMapSwitch.onTintColor = ResourceManager.getColor(.navBarColor)
		cell.switchCellLabel.textColor = ResourceManager.getColor(.textColor)
	}
	
	static func configureRegularCell(_ cell: UITableViewCell) {
		cell.textLabel?.textColor = ResourceManager.getColor(.textColor)
		cell.detailTextLabel?.textColor = ResourceManager.getColor(.additionalTextColor)
		cell.tintColor = ResourceManager.getColor(.navBarColor)
	}
	
	static func configureDescriptionCell(_ cell: DescriptionCell) {
		cell.descriptionTextField.textColor = ResourceManager.getColor(.textColor)
	}
	
	static func configureIconCell(_ cell: IconCell) {
		cell.iconLabel.textColor = ResourceManager.getColor(.textColor)
	}
	
	static func configureSections(_ view: UIView) {
		let contentView = view.subviews[0]
		contentView.backgroundColor = ResourceManager.getColor(.sectionColor)
		let header = view as! UITableViewHeaderFooterView
		header.textLabel?.textColor = ResourceManager.getColor(.sectionTitleColor)
	}
}
