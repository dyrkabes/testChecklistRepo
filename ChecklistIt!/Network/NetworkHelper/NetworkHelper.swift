//
//  NetworkHelper.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 23.11.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import RxSwift
import RxAlamofire


// TODO: generally NetwrokHelper needs a lot of refactor
// Some use of alamofire serialization and auth would be nice
class NetworkHelper {
	static var syncManager: SyncManager = SyncManager()
//	static var responceManager = ResponceManager()
	
	static func getURL(_ serverCommand: ServerCommand) -> String {
		return NetworkSettings.DefaultServerName.rawValue + serverCommand.rawValue
	}
	
	static func createRequestWithURL(_ url: String, andMethod method: String, andParameters parameters: [String: AnyObject]) -> NSMutableURLRequest {
		let request = NSMutableURLRequest(url: URL(string: url)!)
		request.httpMethod = method
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
		request.httpBody = httpBody
		return request
	}
    
    static func getBaseItemsURL(_ type: String) -> String {
        if type == "Checklist" {
            return NetworkHelper.getURL(.ChecklistsForUser)
        } else {
            return NetworkHelper.getURL(.ItemsForUser)
        }
    }
	
	// test method
	static func getActualizationDateWithRX() -> Observable<Double?> {
        print(" **** Getting act date")
		let URL = NetworkHelper.getURL(.GetActualizationDate)
		let (username, password) = DefaultsHelper.getUsernameAndPassword()
		let parameters = ["username": username, "password": password]
		let request = NetworkHelper.createRequestWithURL(URL, andMethod: "POST", andParameters: parameters as [String : AnyObject])
        AppDelegate.networkStatusIcon.changeNetworkStatusIconState(.active)
        
		return URLSession.shared
		.rx
        .json(request: request as URLRequest)
		.retry(3)
			.map {
				responce in
				var actualization: Double?
				
				// todo: remake
                if let responceItems = (responce as? [String : AnyObject])?["responce"] as? [String: AnyObject] {

					if let actualization_date = responceItems["actualization_date"] as? Double {
						actualization = actualization_date
					}
				}
                AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
                    .inactive)
        
				return actualization
		}
	}
	
	
	// Remove after next commit
//	static func getActualizationDate() {
//		print(" **** Getting serverActualizationDate")
//		let URL = NetworkHelper.getURL(.GetActualizationDate)
//		let (username, password) = DefaultsHelper.getUsernameAndPassword()
//		let parameters = ["username": username, "password": password]
//
//		// Icon coloring
//		AppDelegate.networkStatusIcon.changeNetworkStatusIconState(.active)
//		
//		Alamofire.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: RequestConstants.headers
//			).responseJSON { responce in
//				print("Actualization: ", responce.result)
//                if let JSON = responce.result.value as? [String: AnyObject] {
//					if let meta = JSON["meta"],
//					   let error = meta["error"] {
//							guard error == nil else {
//								print("Err: ", error!)
//								if error as! String == "user does not exist" {
//									// handle .. NetworkHelper
//									
//									// Icon coloring
//								    AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
//										.notLoggedIn)
//								}
//								return
//							}
//					}
//					
//					if let responce = JSON["responce"] as? [String: AnyObject],
//					   let actualizationDate = responce["actualization_date"] as? Double {
//							NetworkHelper.syncManager.serverActualizationDate = actualizationDate
//							NetworkHelper.setUpSynchronizationsFlags(actualizationDate)
//						
//							// Icon coloring
//							AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
//							.inactive)
//						
//							NetworkHelper.syncManager.processSync()
//						
//						
//						}
//				}
//		}
//	}
	

	// will be unified as well
	// TODO: Meaning part of function must fit in one screen height
	static func getBaseItemsForUser<EntityType: BaseItem>(_ entityClass: EntityType.Type) {
		print(" **** Getting data from server")
		let stringType = String(describing: entityClass) == "Checklist" ? "checklists" : "items"
		let URL = getBaseItemsURL(String(describing: entityClass))

		var parameters: [String: AnyObject] = [:]
		parameters["username"] = DefaultsHelper.getToken() as AnyObject?

		
		// Icon coloring
		AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
			.active)

        Alamofire.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: RequestConstants.headers
			).responseJSON {
				serverResponce in
				print(" ****Get base items for user")
                let (responce, error) = ResponceValidator.validateJSONResponce(responce: serverResponce)
                guard error == nil else {
                    AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
                        .inactive)
                    return
                }
                let baseItems = responce?[stringType] as! [[String: AnyObject]]
                BaseItemParser.parseBaseItems(baseItems: baseItems, withEntityClass: entityClass)
		}
		

	}
	
	static func sendAllLocalData() {
		print(" **** Sendimg all local data")
		let URL = NetworkHelper.getURL(.UploadAllData)
		var parameters: [String: AnyObject] = [:]
		parameters["username"] = DefaultsHelper.getToken() as AnyObject?
		parameters["actualization_date"] = DefaultsHelper.getLastChangeDate() as AnyObject?
		
		
		
		// TODO: Eliminate code duplication and move it to separate helper
		
		// form checklists
		let checklistsFromDB = ManagedObjectContext.fetch(Checklist.self)
		var checklists: [[String: Any]] = []
		for checklist in checklistsFromDB {
			checklists.append(checklist.mapTo())
		}
		parameters["checklists"] = RepositoryHelper.baseItemsToDict(withEntityClass: Checklist.self) as AnyObject?
        parameters["items"] = RepositoryHelper.baseItemsToDict(withEntityClass: Item.self) as AnyObject?
		
		// Icon coloring
		AppDelegate.networkStatusIcon.changeNetworkStatusIconState(.active)
		
		Alamofire.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: RequestConstants.headers
			).responseJSON { serverResponce in
				print(" ****Uploading all data")
                let (responce, error) = ResponceValidator.validateJSONResponce(responce: serverResponce)
                guard error == nil else {
                    AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
                        .inactive)
                    return
                }
					
                        
                // replace with OK Chls need upload and Items nee download
                if let checklistsUpToDate = responce?[ResponceKey.checklistsUpToDate] as? Bool {
                    if !checklistsUpToDate {
                        NetworkHelper.syncManager.checklistsNeedDownload = true
                    }
                }
                
                if let itemsUpToDate = responce?[ResponceKey.itemsUpToDate] as? Bool {
                    if !itemsUpToDate {
                        NetworkHelper.syncManager.itemsNeedDownload = true
                    }
                }
                
                NetworkHelper.syncManager.checklistsNeedUpload = false
                NetworkHelper.syncManager.itemsNeedUpload = false
                
                DefaultsHelper.setActualizationDate(DefaultsHelper.getLastChangeDate())
                
                // Icon coloring
                AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
                    .inactive)
                
                NetworkHelper.syncManager.processSync()
						
				
		}
	}
	

}


