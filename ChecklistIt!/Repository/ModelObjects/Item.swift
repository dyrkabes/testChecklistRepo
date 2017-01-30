//
//  Item.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 18.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Item: BaseItem {
	override func getType() -> String {
		return "Item"
	}
	
	func isDueDate() -> Bool {
		if let _ = self.dueDate {
			return true
		}
		return false
	}
	
	override func setParameters(_ parameters: [String: AnyObject]) {
		super.setParameters(parameters)
		let checklistFromDB = ManagedObjectContext.fetchChecklistWithID(parameters["checklist_id"] as! String)

		self.checklist = checklistFromDB![0]

		self.descriptionText = parameters["description"] as! String
		self.done = parameters["done"] as! Bool as NSNumber
		
		var itemsDone = checklist.itemsDone as Int
		let itemsOverall = checklist.itemsOverall as Int + 1
		
		if self.done != 0 {
			itemsDone += 1
			self.checklist.itemsDone = itemsDone as NSNumber
		}
		self.checklist.itemsOverall = itemsOverall as NSNumber
		

	}
    
    func decreaseChecklistCounter() {
        var itemsDone = checklist.itemsDone as Int
        let itemsOverall = checklist.itemsOverall as Int - 1
        
        itemsDone = done == 1 ? itemsDone - 1 : itemsDone
        
        checklist.itemsOverall = itemsOverall as NSNumber
        checklist.itemsDone = itemsDone as NSNumber
    }
	
	override func mapTo() -> [String : Any] {
		var parameters = super.mapTo()
		parameters["description"] = self.descriptionText as AnyObject?
		parameters["done"] = self.done
		parameters["checklist_id"] = self.checklist.id as AnyObject?
		return parameters
	}

}
