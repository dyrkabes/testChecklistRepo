//
//  ChecklistViewController.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 17.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit
//import Alamofire


//remove
import CoreData

// why doesnt it see it
//import NetworkSettings

class ChecklistViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	
//	var items: [Item]?
    var dataSource: ChecklistDataSourceProtocol = ChecklistDataSource()
    var currentChecklist: Checklist! {
        get {
            return dataSource.getCurrentChecklist()
        }
        
        set(newValue) {
            dataSource.setCurrentChecklist(currentChecklist: newValue)
        }
    }
	
	var delegate: ContentChangedDelegate?
    var plugView: PlugView?
	
	
	@IBAction func back() {
        delegate?.contentChanged()
		
		dismiss(animated: true, completion: nil)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
//		items = ManagedObjectContext.fetchItemsForChecklist(currentChecklist)
		ColorConfigurator.configureViewController(self)
        tableView.dataSource = dataSource
        dataSource.fetchItems()

    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		AppDelegate.networkStatusIcon.show(self)
        plugView?.startAnimation()
	}
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func toggleImageView(_ indexPath: IndexPath) {
		if let cell = tableView.cellForRow(at: indexPath) as? ChecklistItemCell {
			if let doneImageView = cell.doneImageView {
				doneImageView.isHidden = (dataSource.getItems()[indexPath.row].done == 0)
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let navigationController = segue.destination as! UINavigationController
		let controller = navigationController.topViewController as! AddItemViewController
		controller.currentChecklist = currentChecklist
		controller.delegate = self
		if segue.identifier == "AddItem" {
//			controller.title = "Add Item"
			
		} else if segue.identifier == "EditItem" {
			let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
			controller.itemToEdit = dataSource.getItems()[indexPath!.row]
//			controller.title = "Edit Item"
		}
	}
    
    func addItem() {
        let navigationController = self.storyboard?.instantiateViewController(withIdentifier: "Add" + "Item" + "NavigationController") as! UINavigationController
        let addItemVC = navigationController.viewControllers[0] as! AddItemViewController
        
        addItemVC.delegate = self
        addItemVC.currentChecklist = currentChecklist
        
        present(navigationController, animated: true, completion: nil)
    }

}

extension ChecklistViewController: UITableViewDelegate {
	// Selected a row
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	// Changing the item's and checklist's state
		
		// make it shorter
		var itemsDone = currentChecklist.itemsDone as Int
		if dataSource.getItems()[indexPath.row].done == 0 {
			dataSource.getItems()[indexPath.row].done = 1
			itemsDone += 1
			DefaultsHelper.modifyDoneAdditive(true)
		} else {
			dataSource.getItems()[indexPath.row].done = 0
			itemsDone -= 1
			DefaultsHelper.modifyDoneAdditive(false)
		}
		currentChecklist.itemsDone = itemsDone as NSNumber
		toggleImageView(indexPath)
		ManagedObjectContext.save()
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


extension ChecklistViewController: ContentChangedDelegate {
	func contentChanged() {
        // TODO: if is called by relogin service it probably should redirect to AllChecklists as particular chl is unavaiable
        dataSource.fetchItems()
//		items = ManagedObjectContext.fetchItemsForChecklist(currentChecklist)
		tableView.reloadData()
	}
    
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
        // FIXME: to datasopurce!
        let numberInArray = dataSource.getItems().index(of: dataSource.getItems().filter( { $0.id == itemID })[0] )!
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

extension ChecklistViewController: HasTableView {
	func getTableView() -> UITableView {
		return tableView
	}
	
	func getTableViewState() -> TableViewState {
		return dataSource.getItems().count == 0 ? .empty : .hasItems
	}
}
