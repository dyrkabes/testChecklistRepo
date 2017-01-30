//
//  DefaultsKey.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 11.11.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
enum DefaultsKey: String {
	// General
	case CreationDate = "CreationDate"
	case OpenedTheFirstTime = "OpenedTheFirstTime"
	
	// Statistics
	case ChecklistsAdded = "ChecklistsAdded"
	case ChecklistsArchived = "ChecklistsArchived"
	case ItemsAdded = "ItemsAdded"
	case ItemsDone = "ItemsDone"
	
	// Camera
	case ZoomLevel = "ZoomLevel"
	
	case Username = "Username"
	case Token = "Token"
	case TokenExpiration = "TokenExpiration"
	case Password = "Password"
	case LastChangeDate = "LastChangeDate"
	case ActualizationDate = "ActualizationDate"
	
	// when user is registered or he logged in from the RegisterForm 
	// he should first download everything from server to prevent
	// wipe at server's side
	case InitialUserLoadChecklists = "InitialUserLoadChecklists"
	case InitialUserLoadItems = "InitialUserLoadItems"
	
	// is used for user while he hasn't registered on server
	case TemporaryUsername = "TemporaryUsername"
	case UsernameIsTemporary = "UsernameIsTemporary"
}
