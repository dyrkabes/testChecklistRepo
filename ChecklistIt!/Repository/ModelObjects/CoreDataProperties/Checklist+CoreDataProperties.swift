//
//  Checklist+CoreDataProperties.swift
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

extension Checklist {
    @NSManaged var itemsDone: NSNumber
    @NSManaged var itemsOverall: NSNumber
    @NSManaged var items: NSSet?

}
