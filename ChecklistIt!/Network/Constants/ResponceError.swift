//
//  ResponceErrors.swift
//  ChecklistIt
//
//  Created by Pavel Stepanov on 26/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import Foundation

enum ResponceError: Error {
    case serverError(String)
    case noJSON()
    case noResponce()
//    static let userAlreadyExists = "User already exists"
}
