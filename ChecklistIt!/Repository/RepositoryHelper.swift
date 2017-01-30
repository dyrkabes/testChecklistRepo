//
//  RepositoryHelper.swift
//  ChecklistIt
//
//  Created by Pavel Stepanov on 29/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import CoreData

struct RepositoryHelper {
    static func purgeOldItems(_ databaseBaseItems: [BaseItem], excludingLocalIDs localIDs: [String]) {
        for dbBaseItem in databaseBaseItems {
            var wasInResponce: Bool = false
            //leaving alone all baseItems that were in responce
            for localID in localIDs {
                if dbBaseItem.id == localID {
                    wasInResponce = true
                    break
                }
            }
            
            if !wasInResponce {
                if (dbBaseItem.changeDate as Double) < NetworkHelper.syncManager.serverActualizationDate {
                    // if was not in updating request (was not on server) and is old
                    if let item = dbBaseItem as? Item {
                        print("Item w dele")
                        item.decreaseChecklistCounter()
                    }
                    
                    
                    ManagedObjectContext.deleteEntity(dbBaseItem)
                }
            }
            
        }
        ManagedObjectContext.save()
    }
    
    static func baseItemsToDict<EntityType: BaseItem>(withEntityClass entityClass: EntityType.Type) -> [[String: Any]] {
        let baseItemsFromDB = ManagedObjectContext.fetch(entityClass) 
        var baseItems: [[String: Any]] = []
        for baseItem in baseItemsFromDB {
            baseItems.append(baseItem.mapTo())
        }
        return baseItems
    }
}
