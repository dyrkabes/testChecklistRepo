//
//  NetworkHelperSignFunctions.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 23.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Alamofire

extension NetworkHelper {
	static func register() {
		let URLString = NetworkHelper.getURL(.Register)
		let (username, password) = DefaultsHelper.getUsernameAndPassword()
        let parameters: [String : Any] = ["username": username, "password": password]
		// Netwrok icon coloring
		AppDelegate.networkStatusIcon.changeNetworkStatusIconState(.active)
		
        Alamofire.request(URLString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: RequestConstants.headers).responseJSON { responce in
                print(" ****Register: ", responce.result)
                if let JSON = responce.result.value as? [String: AnyObject] {
                    if let meta = JSON["meta"] {
                        if let error = meta["error"] as? String{
                            SignResponceManager.signFunctionFinished(withResponce: SignResponce.failure(error))

                            AppDelegate.networkStatusIcon.changeNetworkStatusIconState(.notLoggedIn)
                            return
                        }
                    }

                    if let responce = JSON["responce"] as? [String: AnyObject] {
                        let token = responce["token"] as! String
                        let tokenExpiration = responce["expiration"] as! Double
                        DefaultsHelper.setToken(token)
                        DefaultsHelper.setTokenExpiration(tokenExpiration)
                        SignResponceManager.signFunctionFinished(withResponce: SignResponce.success())
    //                    ResponceManager.signFunctionFinished(
    //                        withResult: "success")

                        ManagedObjectContext.replaceTemporaryUsername()
                        DefaultsHelper.setPersistentUsername(username)
                        NetworkHelper.syncManager.processSync()
                        // Icon coloring
                        AppDelegate.networkStatusIcon.changeNetworkStatusIconState(.inactive)
                        
                    }
                } else {

                    // lying
                    SignResponceManager.signFunctionFinished(withResponce: SignResponce.failure("No connection to server"))
    //                ResponceManager.signFunctionFinished(withResult: "failure", andError: "no connection ot server")
                    // Icon coloring
                    AppDelegate.networkStatusIcon.changeNetworkStatusIconState(.notLoggedIn)
                }

        }
	}
	
	
	static func login() {
		let URL = NetworkHelper.getURL(.Login)
		let (username, password) = DefaultsHelper.getUsernameAndPassword()
        let parameters: [String : Any] = ["username": username, "password": password]
//		let request = createRequestWithURL(URL, andMethod: "POST", andParameters: parameters as [String : AnyObject])
//		NetworkHelper.responceManager.loginRequestProcessing = true
		
		// Icon coloring
		AppDelegate.networkStatusIcon.changeNetworkStatusIconState(.active)
		
//		Alamofire.request(request as! URLRequestConvertible
        Alamofire.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: RequestConstants.headers)
            .responseJSON { responce in
				print(" ****Login: ", responce.result)
				if let JSON = responce.result.value as? [String: AnyObject] {
					if let meta = JSON["meta"] as? [String: AnyObject] {
						if let error = meta["error"] as? String {
                            SignResponceManager.signFunctionFinished(withResponce: SignResponce.failure("failure"))
//							ResponceManager.signFunctionFinished(withResult: "failure", andError: error)
//							// Icon coloring
							AppDelegate.networkStatusIcon.changeNetworkStatusIconState(.notLoggedIn)
							return
						}
					}
					
					if let responce = JSON["responce"] as? [String:AnyObject] {
						let token = responce["token"] as! String
						let tokenExpiration = responce["expiration"] as! Double
						
						
						DefaultsHelper.setToken(token)
						DefaultsHelper.setTokenExpiration(tokenExpiration)
						
						ManagedObjectContext.replaceTemporaryUsername()
						DefaultsHelper.setPersistentUsername(username)
						
                        SignResponceManager.signFunctionFinished(withResponce: SignResponce.success())
                        
//                        ResponceManager.signFunctionFinished(withResponce: SignResponce.success()))
//						ResponceManager.signFunctionFinished(withResult: "success")
						
						// Icon coloring
						AppDelegate.networkStatusIcon.changeNetworkStatusIconState(.inactive)
					}
				}
		}
	}
}
