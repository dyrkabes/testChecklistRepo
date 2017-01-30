//
//  BaseItemParser.swift
//  ChecklistIt
//
//  Created by Pavel Stepanov on 28/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import Foundation
import CoreData

struct BaseItemParser {
    static func parseBaseItems<EntityType: BaseItem> (baseItems: [[String: AnyObject]], withEntityClass entityClass: EntityType.Type) {

            // local items to compare and replace
            let databaseBaseItems = ManagedObjectContext.fetch(entityClass)

            // is used to purge old database baseItems later
            var localIDs: [String] = []
        
            // iterating through responce's items
            for baseItem in baseItems {
                // to determine if we need to create new baseItem in local database
                var foundOneInDatabase: Bool = false
                
                // iterating through database to find if there's such item
                for dbBaseItem in databaseBaseItems {
                    if dbBaseItem.id == baseItem["local_id"] as! String {
                        foundOneInDatabase = true
                        localIDs.append(baseItem["local_id"] as! String)
                        
                        // if item is older than the one on server
                        if ((dbBaseItem.changeDate as Double)) < (baseItem["change_date"] as! Double) {
                            // updating DB baseItem
                            if dbBaseItem is Checklist {
                                (dbBaseItem as! Checklist).setParameters(baseItem)
                            } else {
                                (dbBaseItem as! Item).setParameters(baseItem)
                            }
                            //											dbBaseItem.setParameters(baseItem)
                            
                        } else if ((dbBaseItem.changeDate as Double)) > (baseItem["change_date"] as! Double) {
                            // It is an option if we made a newer baseItem but have not uploaded it yet. It wont be affected and on the next sync it will be uploaded
                            
                            
                            if dbBaseItem is Checklist {
                                NetworkHelper.syncManager.checklistsNeedUpload = true
                            } else {
                                NetworkHelper.syncManager.itemsNeedUpload = true
                            }
                        }
                        break
                    }
                }
                
                if !foundOneInDatabase {
                    // new checklist from backend
                    var parameters = baseItem
                    if String(describing: entityClass) == "Item" {
                        // checking if item has any checklist or it just persists in server's db for no reason. Testing issue
                        let checklistFromDB = ManagedObjectContext.fetchChecklistWithID(parameters["checklist_id"] as! String)
                        guard checklistFromDB! != [] else {
                            // should not occur on working server
                            print("there's no checklist for the item")
                            continue
                        }
                    }
                    
                    // create new DB record
                    let baseItemToInsert = ManagedObjectContext.insertEntity(entityClass) as! EntityType
//                    EntityType
                    parameters["username"] = DefaultsHelper.getUsername() as AnyObject?
                    baseItemToInsert.setParameters(parameters)
                    localIDs.append(parameters["local_id"]! as! String)
                }
            }
            
            // Cleaning db from items that do not exist on back end and are older than its actualization date
            // New items are excluded but we dont need to purge them
            RepositoryHelper.purgeOldItems(databaseBaseItems, excludingLocalIDs: localIDs)
            
            // setting flags
            NetworkHelper.syncManager.itemsDownloadComplete(withItemsType: String(describing: entityClass))
        
            // Icon coloring
            AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
                .inactive)
            
            NetworkHelper.syncManager.processSync()

            // if there're more chls - server lacks info
            
            
            
        
    }
    
    
}

protocol BaseItemParserProtocol {
    
}
