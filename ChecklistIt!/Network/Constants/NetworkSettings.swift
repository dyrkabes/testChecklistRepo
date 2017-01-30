//
//  NetworkConfigs.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 22.11.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation

enum NetworkSettings: String {
	case DefaultServerName = "http://ec2-54-174-179-155.compute-1.amazonaws.com"
}

enum ServerCommand: String {
	case AddChecklist = "/add_checklist"
	case AddItem = "/add_item"
	
	
	// check APIs. Make APIs
	case ChecklistsForUser = "/checklists_for_user"
	case ItemsForUser = "/items_for_user"
	case ItemsOfChecklist = "/items_of_checklist"
	
	
	// Make APIs
	case DeleteItem = "/delete_item"
	case DeleteChecklist = "/delete_checklist"
	
	case UploadAllData = "/upload_all_data"
	
	// Register on server with specified username and password
	case Register = "/register"
	
	// To get token if expired
	case Login = "/login"
	
	case GetActualizationDate = "/get_actualization_date"
    
    case leaveFeedback = "/leave_feedback"
    case getAllFeedback = "/get_all_feedback"
}



