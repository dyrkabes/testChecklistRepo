//
//  BaseItem.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 31.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class BaseItem: NSManagedObject {
	func isAbleToShow() -> Bool {
		return self.showOnMap == 1
	}
	
	func getEntityLocation() -> CLLocationCoordinate2D {
		let location = self.location!
		return CLLocationCoordinate2DMake(
			(location.latitude) as Double,
			(location.longitude) as Double)
	}
	
	func getType() -> String {
		return "BaseItem"
	}
	
	func setParameters(_ parameters: [String: AnyObject]) {
		if let id = parameters["local_id"] as? String {
			self.id = id
		} else { self.id = parameters["id"] as! String }
		self.name = parameters["name"] as! String
		
		if let showOnMap = parameters["show_on_map"] as? Bool {
		    self.showOnMap = showOnMap as NSNumber
			if self.showOnMap == 1 {
                // TODO: ugly
				self.location = ManagedObjectContext.insertEntity(Location.self) as? Location
				self.location!.latitude = ((parameters["location_latitude"] as? Double)!) as NSNumber
				self.location!.longitude = ((parameters["location_longitude"] as? Double)!) as NSNumber
			}  else {
				self.location = nil
			}
		} else {
			//TODO: remove afetr server updates
			self.showOnMap = false
			self.location = nil
		}
		
		self.category = parameters["category"] as! String
		
		if let creationDate = parameters["creation_date"] as? Double,
			let changeDate = parameters["change_date"] as? Double {
			self.creationDate = creationDate as NSNumber
			self.changeDate = changeDate as NSNumber
		}
		
		
		
		
		self.status = parameters["status"] as! String

		self.username = DefaultsHelper.getUsername()
	}
	

	

}

extension BaseItem: Mappable {
	func mapTo() -> [String: Any] {
		var parameters = [String: AnyObject]()
		parameters["local_id"] = self.id as AnyObject?
		parameters["name"] = self.name as AnyObject?
		parameters["category"] = self.category as AnyObject?
		
		
		parameters["show_on_map"] = self.showOnMap
		parameters["location_longitude"] = self.location?.longitude
		parameters["location_latitude"] = self.location?.latitude
		
		
//		parameters["address"] = self.address
		parameters["creation_date"] = self.creationDate
		parameters["change_date"] = self.changeDate
		parameters["status"] = self.status as AnyObject?
		
		return parameters
		
	}
	
	func mapOut(_ dictTopUnmap: [String: Any]) {
//		category
//		name
//		showOnMap
//		location
//		address
//		creationDate
	}
}


protocol Mappable {
	func mapTo() -> [String: Any]
    func mapOut(_ dictTopUnmap: [String: Any])
}
