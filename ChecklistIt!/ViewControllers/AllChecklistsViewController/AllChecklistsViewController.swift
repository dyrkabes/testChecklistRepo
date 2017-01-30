//
//  ChecklistsViewController.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 17.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import Alamofire

import SnapKit

// Issue: doesnt refresh TW if was logged in from cloud from another page
// and doesnt sync for some reason (not here)
class AllChecklistsViewController: UIViewController, UITableViewDelegate {
	@IBOutlet weak var tableView: UITableView!
    var dataSource: AllChecklistsDataSourceProtocol!
    var plugView: PlugView?
    
	override func viewDidLoad() {
		super.viewDidLoad()
        dataSource = AllChecklistsDataSource()
        dataSource.fetchChecklists()
        tableView.dataSource = dataSource

		ColorConfigurator.configureViewController(self)
		
		// TODO: First time only or while not logged in
		registerOffer()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		AppDelegate.networkStatusIcon.show(self)
        plugView?.startAnimation()
	}
//
	// move to InfoMessageHelper I guess
	func registerOffer() {
		// if starts the first time
		let registerForm = RegisterForm()
        registerForm.addToParentView(parentView: view, peeking: true)
		
	}
	
	
	// remove unused parts
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let navigationController = segue.destination as! UINavigationController
//code duplication
		if segue.identifier == "AddChecklist" {
			let controller = navigationController.topViewController as! AddChecklistViewController
			controller.delegate = self
		}
        else if segue.identifier == "EditChecklist" {
			let controller = navigationController.topViewController as! AddChecklistViewController
			controller.delegate = self
			if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
				controller.checklistToEdit = dataSource.getChecklists()[indexPath.row]
			}
		}
        else if segue.identifier == "ViewItems" {
			let controller = navigationController.topViewController as! ChecklistViewController
			if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
			    controller.currentChecklist = dataSource.getChecklists()[indexPath.row]
				controller.delegate = self
				controller.title = dataSource.getChecklists()[indexPath.row].name
			}
		}
	}
    
    func addChecklist() {
        let navigationController = self.storyboard?.instantiateViewController(withIdentifier: ViewControllerConstants.addChecklistNavigationController) as! UINavigationController
        let addChecklistVC = navigationController.viewControllers[0] as! AddChecklistViewController
        addChecklistVC.delegate = self
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let tempoPlugView = ViewControllerHelper.showFooterOrPlug(self)
        plugView = tempoPlugView as? PlugView
        plugView?.parentViewController = self
        return tempoPlugView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return ViewControllerHelper.getFooterHeight(self)
    }
}

extension AllChecklistsViewController: ContentChangedDelegate {
	func contentChanged() {
        dataSource.fetchChecklists()
		tableView.reloadData()
	}
    
        // unify, make prettier
    func addAnimation(category: String, itemID: String) {
        let categoryImageView = UIImageView()
        if category != "No category" {
            categoryImageView.image = ResourceManager.getImageWithCategory(category).withRenderingMode(.alwaysTemplate)
        } else {
            // new image needed
            categoryImageView.image = UIImage(named: "Add")!.withRenderingMode(.alwaysTemplate)
        }
        categoryImageView.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.55)
        
        let parentView = self.navigationController!.view!
        
        // that's hilarious
        let checklists = dataSource.getChecklists()
        let numberInArray = checklists.index(of: checklists.filter( { $0.id == itemID })[0] )!
        // dislike it
        let tableRowHeight = 44
        
        // 60 - navItem height. Fix me
        let offsetFromTop = tableRowHeight * numberInArray + 60
        
        var duration = TimeInterval(offsetFromTop / 450)
        if duration < 0.8 {
            duration = 0.8
        }
        
        parentView.addSubview(categoryImageView)
        categoryImageView.snp.makeConstraints {
            //            $0.centerX.equalTo(parentView.snp.centerX)
            $0.left.equalTo(parentView.snp.left).offset(30)
            $0.top.equalTo(parentView.snp.top).offset(offsetFromTop)
            $0.width.equalTo(36)
            $0.height.equalTo(36)
        }
        parentView.layoutIfNeeded()
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                categoryImageView.snp.remakeConstraints {
                    //                    $0.centerX.equalTo(parentView.snp.centerX)
                    $0.left.equalTo(parentView.snp.left).offset(30)
                    $0.top.equalTo(parentView.snp.top).offset(offsetFromTop/2)
                    $0.width.equalTo(36)
                    $0.height.equalTo(36)
                }
                parentView.layoutIfNeeded()
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7) {
                categoryImageView.snp.remakeConstraints {
                    $0.right.equalTo(parentView.snp.right).dividedBy(1.4)
                    $0.top.equalTo(parentView.snp.top).offset(20)
                    //                    $0.centerY.equalTo(parentView.snp.centerY)
                    $0.width.equalTo(10)
                    $0.height.equalTo(10)
                }
                categoryImageView.alpha = 0
                parentView.layoutIfNeeded()
            }
            
            
            parentView.layoutIfNeeded()
        }, completion: {
            _ in
            categoryImageView.removeFromSuperview()
        })
    }
}

extension AllChecklistsViewController: HasTableView {
	func getTableView() -> UITableView {
		return tableView
	}
	
	func getTableViewState() -> TableViewState {
		return dataSource.getChecklists().count == 0 ? .empty : .hasItems
	}
}

//extension UITextField {
//    func textRect(forBounds bounds: CGRect) -> CGRect {
//        let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
//        return UIEdgeInsetsInsetRect(bounds, padding)
//    }
//    
////    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
////        let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
////        return UIEdgeInsetsInsetRect(bounds, padding)
////    }
////    
////    override func editingRect(forBounds bounds: CGRect) -> CGRect {
////        let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
////        return UIEdgeInsetsInsetRect(bounds, padding)
////    }
//}
