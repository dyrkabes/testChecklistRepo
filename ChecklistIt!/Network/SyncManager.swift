//
//  SyncManager.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 30.11.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit
import RxSwift

// Responsible for guiding synchronization process
class SyncManager {
	// all is synced
	var synced = false
	
	// data on local device is old
	var checklistsNeedDownload = false
	var itemsNeedDownload = false
	
	// actualization date from server
	var serverActualizationDate = -1.0
	
	//	is used to process server's old data
	var checklistsNeedUpload = false
	var itemsNeedUpload = false
	
	// is used to refresh AllChecklistVC if data was downloaded
	var dataWasDownloaded = false
    
    let disposeBag = DisposeBag()
	
	// central point in sync process
	func processSync() {
        // TODO: On relogin from one device a bit more requests are made then intended. Not crucial tho
		guard !(DefaultsHelper.getDefaultByKey(.UsernameIsTemporary) as! Bool) else {
			return
		}
		
        // If it is user's first time download everything from server
		checkInitialUserLoad()

		guard serverActualizationDate >= 0 else {
			// ask server for its actualization date
            NetworkHelper.getActualizationDateWithRX().asObservable()
                .subscribe(onNext: { actualization in
                    NetworkHelper.syncManager.serverActualizationDate = actualization!
                    NetworkHelper.syncManager.setUpSynchronizationsFlags(actualization!)
                    // init new sync process as new actuazliation has arrived
                    NetworkHelper.syncManager.processSync()
                    
                }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
			return
		}
		
        // upload all user's data
		guard !checklistsNeedUpload || !itemsNeedUpload else {
			let functor = Functor(function: NetworkHelper.sendAllLocalData)
			functor.processRequestWithRequestedLoginWithManagedObjectWithoutSyncCheck()
			return
		}
		
        // download checklists
		guard !checklistsNeedDownload else {
			dataWasDownloaded = true
			let functor = Functor(function: NetworkHelper.getBaseItemsForUser)
		    functor.processRequestWithRequestedLoginWithManagedObjectWithoutSyncCheck(
				Checklist.self)
			return
		}
		
        // and items after checklists
		guard !itemsNeedDownload else {
			dataWasDownloaded = true
			
			let functor = Functor(function: NetworkHelper.getBaseItemsForUser)
			functor.processRequestWithRequestedLoginWithManagedObjectWithoutSyncCheck(Item.self)
			return
		}
		print(" ****Synced")
		
		synced = true
        
        // Checking and sending feedbacks which were not sent
        FeedbackHelper.checkForNotSent()
        
		if dataWasDownloaded {
            if let viewController = UIApplication.topViewController() as? ContentChangedDelegate {
                viewController.contentChanged()
            }
			dataWasDownloaded = false
		}
        
        // TODO: send new local actualization to server to eliminate second round of sync
        // lacks server side
	}
	
	
	// downloads everything on first local login/register
	func checkInitialUserLoad() {
		switch DefaultsHelper.getInitialUserLoad() {
		case (false, _):
			// download checklists
			let functor = Functor(function: NetworkHelper.getBaseItemsForUser)
			functor.processRequestWithRequestedLoginWithManagedObjectWithoutSyncCheck(
				Checklist.self)
			return
		case (true, false):
			// download items
			let functor = Functor(function: NetworkHelper.getBaseItemsForUser)
			functor.processRequestWithRequestedLoginWithManagedObjectWithoutSyncCheck(
				Item.self)
			return
		default:
			break
		}
	}

    func setUpSynchronizationsFlags(_ actualizationDate: Double) {
        // TODO: remove rounds after sync fixed
        let localActualizationDate = DefaultsHelper.getActualiztionDate()
        let lastChangeDate = DefaultsHelper.getLastChangeDate()
        
        print(lastChangeDate)
        print(localActualizationDate)
        print(actualizationDate)
        
        if actualizationDate > localActualizationDate {
            // download needed
            checklistsNeedDownload = true
            itemsNeedDownload = true
            synced = false
        } else if (actualizationDate < localActualizationDate ||
            lastChangeDate > actualizationDate )
        {
            // upload needed
            checklistsNeedUpload = true
            itemsNeedUpload = true
            synced = false
        } else {
            synced = true
        }
    }

	func resetParameters() {
		synced = false
		checklistsNeedDownload = false
		itemsNeedDownload = false
		serverActualizationDate = -1.0
		checklistsNeedUpload = false
		itemsNeedUpload = false
	}
	
	func getSyncStatus() -> Bool {
		return synced
	}
    
    func itemsDownloadComplete(withItemsType itemsType: String) {
        if itemsType == "Checklist" {
            NetworkHelper.syncManager.checklistsNeedDownload = false
            DefaultsHelper.setInitialUserLoadChecklist(true)
        } else {
            NetworkHelper.syncManager.itemsNeedDownload = false
            DefaultsHelper.setInitialUserLoadItems(true)
            DefaultsHelper.setActualizationDate(serverActualizationDate)
        }
    }
	
}
