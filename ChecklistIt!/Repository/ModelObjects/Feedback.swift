//
//  Feedback.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 14/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import Foundation
import CoreData


class Feedback: NSManagedObject {
    

    
}

extension Feedback: Mappable {
    func mapTo() -> [String: Any] {
        var parameters = [String: AnyObject]()
        parameters["local_id"] = self.id as AnyObject
        parameters["title"] = self.title as AnyObject
        parameters["text"] = self.text as AnyObject
        
        // sending status is useless
//        parameters["status"] = self.status as AnyObject
        parameters["date"] = self.date as AnyObject
        parameters["anonymously"] = self.anonymously
        parameters["responce"] = self.responce as AnyObject
        return parameters
        
    }

    func mapOut(_ dictTopUnmap: [String: Any]) {
        self.id = dictTopUnmap["local_id"] as! String
        self.title = dictTopUnmap["title"] as! String
        self.text = dictTopUnmap["text"] as! String
        self.username = DefaultsHelper.getUsername()
        
        
        self.status = dictTopUnmap["status"] as! String
        self.date = dictTopUnmap["date"] as! NSNumber
        self.anonymously = false
        self.responce = dictTopUnmap["responce"] as! String
    }
}
