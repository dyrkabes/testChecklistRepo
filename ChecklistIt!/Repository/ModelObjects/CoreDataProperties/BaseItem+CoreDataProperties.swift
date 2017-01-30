//
//  BaseItem+CoreDataProperties.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 31.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BaseItem {

	@NSManaged var id: String
    @NSManaged var category: String
    @NSManaged var name: String
    @NSManaged var showOnMap: NSNumber
    @NSManaged var location: Location?
	@NSManaged var address: String?
	@NSManaged var creationDate: NSNumber
	@NSManaged var changeDate: NSNumber
	@NSManaged var status: String
	@NSManaged var username: String
	
}




