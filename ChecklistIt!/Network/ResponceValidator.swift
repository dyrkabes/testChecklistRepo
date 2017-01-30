//
//  ResponceValidator.swift
//  ChecklistIt
//
//  Created by Pavel Stepanov on 27/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import Foundation
import Alamofire


struct ResponceValidator {
    static func validateJSONResponce(responce: DataResponse<Any>) -> ([String: AnyObject]?, ResponceError?) {
        guard let serverResponce = responce.result.value as? [String: AnyObject] else {
            return (nil, ResponceError.noJSON())
        }
        
        if let meta = serverResponce[ResponceKey.meta] {
            if let error = meta[ResponceKey.error] as? String {
                return (nil, ResponceError.serverError(error))
            }
        }
        
        guard let responceData = serverResponce[ResponceKey.responce] as? [String: AnyObject] else {
            return (nil, ResponceError.noResponce())
        }
        
        return (responceData, nil)
    }
}
