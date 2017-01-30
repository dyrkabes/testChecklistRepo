//
//  Feedback+CoreDataProperties.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 14/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import Foundation
import CoreData

extension Feedback {
    @NSManaged var title: String
    @NSManaged var date: NSNumber
    @NSManaged var text: String
    @NSManaged var username: String
    @NSManaged var status: String
    @NSManaged var id: String
    @NSManaged var anonymously: NSNumber
    @NSManaged var responce: String
    
}
