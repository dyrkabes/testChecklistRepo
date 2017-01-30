//
//  Checklist.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 18.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Checklist: BaseItem {
	
	func getItemsDoneString() -> String {
		return("Items: done \(self.itemsDone) of \(self.itemsOverall)" )
	}
	
	override func getType() -> String {
		return "Checklist"
	}
	
	override func setParameters(_ parameters: [String: AnyObject]) {
	    super.setParameters(parameters)
	}
	

}

