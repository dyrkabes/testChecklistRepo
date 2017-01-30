//
//  File.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 23.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Alamofire

extension NetworkHelper {
	static func addBaseItem(_ baseItem: BaseItem) {
		let URL: String
		URL = baseItem is Checklist ? NetworkHelper.getURL(.AddChecklist) : NetworkHelper.getURL(.AddItem)
		
		var parameters = baseItem.mapTo()
		parameters["username"] = DefaultsHelper.getToken() as AnyObject?
		
		parameters["actualization_date"] = baseItem.changeDate
		
		// Icon coloring
		AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
			.active)
		
        // TODO: URLRequestConvertible get a knowledge what it is
		Alamofire.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: RequestConstants.headers
			).responseJSON {
				responce in
				print(" ****Add chls/item: ", responce.result)
                if let JSON = responce.result.value as? [String: AnyObject] {
					// handle error
					if let meta = JSON["meta"] as? [String: AnyObject] {
						if let error = meta["error"] as? String {
							print(error)
							// Icon coloring
							AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
								.notLoggedIn)
							return
						}
						
					}
					
					if let _ = JSON["responce"] as? [String: AnyObject] {
						DefaultsHelper.setActualizationDate(parameters["actualization_date"] as! Double)
					}
					
					// Icon coloring
					AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
						.inactive)
				} else {
					// Icon coloring
					AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
						.notLoggedIn)
				}
		}
		
	}
	
	static func deleteBaseItem(_ localID: String, itemType type: String) {
		
		let URL = type == "Checklist" ? NetworkHelper.getURL(.DeleteChecklist) : NetworkHelper.getURL(.DeleteItem)
		
		
		let (username, password) = DefaultsHelper.getUsernameAndPassword()
        //todo: AnyoBj? Looks awful
		let parameters: [String: AnyObject] = ["username": username as AnyObject, "password": password as AnyObject, "local_id": localID as AnyObject, "actualization_date": NSDate().timeIntervalSince1970 as AnyObject]
		
		// Icon coloring
		AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
			.active)
		
		Alamofire.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: RequestConstants.headers
			).responseJSON { responce in
				print(" ****Deleting", responce.result)
                if let JSON = responce.result.value as? [String: AnyObject] {
					//					print("JSON: ", JSON)
                    if let meta = JSON["meta"] as? [String: AnyObject]{
						if let error = meta["error"] {
                            print("Err: ", error)
                            return
						}
					}
					
					if let responce = JSON["responce"] as? [String: AnyObject] {
						print(responce)
						DefaultsHelper.setActualizationDate((parameters["actualization_date"] as? Double)!)
						
						
						
					}
					// Icon coloring
					AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
						.inactive)
				}
		}
	}

}
