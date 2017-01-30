//
//  Location+CoreDataProperties.swift
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

extension Location {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var item: BaseItem

}
