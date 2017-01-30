//
//  NetworkHelperFunctor.swift
//  ChecklistIt
//
//  Created by Pavel Stepanov on 27/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import Alamofire

// checks if token has expired and requests a new one before sending the request
class Functor<T1, T2> {
    let function: (T1) -> T2
    
    init(function: @escaping (T1) -> T2) {
        // function to wrap
        self.function = function
    }
    
    
    // TODO:  make it private and replace all 
    func run(_ args: T1) -> T2 {
        // execute wrapped function
        return function(args)
    }
    
    func processRequestWithRequestedLoginWithManagedObjectWithoutSyncCheck(_ managedObject: T1) {
        let tokenExpiration = Double(DefaultsHelper.getDefaultByKey(.TokenExpiration) as! Int)
        if tokenExpiration > Date().timeIntervalSince1970 {
            _ = self.run(managedObject)
        } else {
            // token is outdated. Getting new
            let (username, password) = DefaultsHelper.getUsernameAndPassword()
            let URL = NetworkHelper.getURL(.Login)
            let parameters = ["username": username, "password": password]
            
            // TODO: (later) Fix all posts. They're not posts!
            Alamofire.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: RequestConstants.headers
                ).responseJSON { serverResponce in
                    let (responce, error) = ResponceValidator.validateJSONResponce(responce: serverResponce)
                    guard error == nil else {
                        AppDelegate.networkStatusIcon.changeNetworkStatusIconState(
                            .inactive)
                        return
                    }
                    if let token = responce?[ResponceKey.token] as? String,
                        let tokenExpiration = responce?[ResponceKey.tokenExpiration] as? Double {
                        DefaultsHelper.setToken(token)
                        DefaultsHelper.setTokenExpiration(tokenExpiration)
                        // perfoming the intended function
                        _ = self.run(managedObject)
                    }
                }
            }
    }
    
    // If any request is created and data is not synced, sync process is called
    func processRequestWithRequiredLoginWithManagedObject(_ managedObject: T1) {
        if NetworkHelper.syncManager.synced != true {
            NetworkHelper.syncManager.processSync()
            return
        }
        self.processRequestWithRequestedLoginWithManagedObjectWithoutSyncCheck(managedObject)
    }
}
