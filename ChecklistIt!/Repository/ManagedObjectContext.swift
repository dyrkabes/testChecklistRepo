//
//  ManagedObjectContext.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 18.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
import CoreData

class ManagedObjectContext {
	static var applicationDomainDirectory: URL = {
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//		print(urls[urls.count - 1])
		return urls[urls.count - 1]
	}()
	
	static var managedObjectModel: NSManagedObjectModel = {
		let modelURL = Bundle.main.url(forResource: "DataModel", withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()
	
	static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
		let url = applicationDomainDirectory.appendingPathComponent("DataModel.sqlite")
		var failureReason = "There was a failure creating or loading app's saved data"
		
		do {
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
		} catch {
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to init app's saved data" as AnyObject?
			dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
			
			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_SOMAIN", code: 9999, userInfo: dict)
			NSLog("Unresoved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		}
		return coordinator
	}()
	
	static var managedObjectContext: NSManagedObjectContext = {
		let coordinator = persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()

	
	static func save(){
		do {
			try managedObjectContext.save()
			DefaultsHelper.setLastChangeDate()
		} catch {
			let saveError = error as NSError
			print("Make exception work", saveError)
		}

	}
	
	static func rollback() {
		managedObjectContext.rollback()
	}

	static func insertEntity<EntityType: NSManagedObject>(_ entityClass: EntityType.Type) -> NSManagedObject {
		let bufEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: entityClass), into:ManagedObjectContext.managedObjectContext)
		return bufEntity
	}
	
	static func fetch<EntityType: NSManagedObject>(_ entityClass: EntityType.Type) -> [EntityType] {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
		
		let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: entityClass), in: managedObjectContext)
		
		fetchRequest.entity = entityDescription
		
		
		let username = DefaultsHelper.getUsername()
		let predicate = NSPredicate(format: "%K == %@", "username", username)
		fetchRequest.predicate = predicate
		
        // TODO: make it not that ugly
        let sortKey = String(describing: EntityType.self) == String(describing: Feedback.self) ? "title" : "name"
		let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: true)
        
		fetchRequest.sortDescriptors = [sortDescriptor]
		do {
			let result = try managedObjectContext.fetch(fetchRequest) as! [EntityType]
			return result
		} catch {
			let fetchError = error as NSError
			print(fetchError)
		}
		return []
	}
	
	
	
	
	static func fetchItemsForChecklist(_ checklist: Checklist) -> [Item]? {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
		let entityDescription = NSEntityDescription.entity(forEntityName: "Item", in: managedObjectContext)
		
		fetchRequest.entity = entityDescription
		
		let username = DefaultsHelper.getUsername()
		let predicate = NSPredicate(format: "%K == %@", "checklist", checklist)
		let anotherPredicate = NSPredicate(format: "%K == %@", "username", username)
		fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [predicate, anotherPredicate])
		
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		do {
			let result = try managedObjectContext.fetch(fetchRequest) as? [Item]
			return result
		} catch {
			let fetchError = error as NSError
			print(fetchError)
			return nil
		}
	}
	
	static func fetchChecklistWithID(_ id: String) -> [Checklist]? {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
		let entityDescription = NSEntityDescription.entity(forEntityName: "Checklist", in: managedObjectContext)
		
		fetchRequest.entity = entityDescription
		
		let predicate = NSPredicate(format: "id == %@", argumentArray: [id])
		fetchRequest.predicate = predicate
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		do {
			let result = try managedObjectContext.fetch(fetchRequest) as? [Checklist]
			return result
		} catch {
			let fetchError = error as NSError
			print(fetchError)
			return nil
		}
	}

	
	// todo: item
	static func deleteEntity<EntityType: BaseItem>(_ entity: EntityType) {
		if entity is Checklist {
			if let itemsToDelete = ManagedObjectContext.fetchItemsForChecklist(entity as! Checklist)
			{
				for item in itemsToDelete {
//					recentlyDeleted.append(item)
					ManagedObjectContext.deleteEntity(item)
				}
			}
			NetworkHelper.deleteBaseItem(entity.id, itemType: "Checklist")
			// network checklist. items will be deleted automatically
		} else {
			NetworkHelper.deleteBaseItem(entity.id, itemType: "Item")
		}
		managedObjectContext.delete(entity)
		ManagedObjectContext.save()
	}
	
	
	// Move to helper
	static func replaceTemporaryUsername() {
		var baseItems: [BaseItem] = ManagedObjectContext.fetch(Checklist.self) as [BaseItem]
		baseItems.append(contentsOf: ManagedObjectContext.fetch(Item.self) as [BaseItem])
		let temporaryUsername = DefaultsHelper.getDefaultByKey(.TemporaryUsername) as! String
		let persistentUsername = DefaultsHelper.getDefaultByKey(.Username) as! String
		
		
		// excessive with new fetchRequest
		for baseItem in baseItems {
			if baseItem.username == temporaryUsername {
				baseItem.username = persistentUsername
			}
		}
		ManagedObjectContext.save()
		
	}
}
