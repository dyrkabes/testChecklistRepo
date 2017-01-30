//
//  ResponceManager.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 08.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//


// Is used to track non silent (register and login) operations' results and show them to user if needed
import UIKit
import SnapKit
import Foundation

class SignResponceManager {
    static func signFunctionFinished(withResponce responce: SignResponce) {
        let style: InfoMessageType
        let infoMessageText: String
        
        switch responce {
        case .success():
            style = .success
            infoMessageText = "success"
            NetworkHelper.syncManager.processSync()
        case .failure(let errorMessage):
            if errorMessage == "User already exists" {
                NetworkHelper.login()
                return
            }
            style = .error
            infoMessageText = errorMessage
        }
        InfoMessageHelper.createInfoMessageWithText(infoMessageText, andStyle: style)
    }
}
