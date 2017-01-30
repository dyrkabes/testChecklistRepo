//
//  DefaultsHelper.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 11.11.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation


class DefaultsHelper {
	static func registerDefaults() {
		let temporaryUsername = UUID().uuidString
		let dictionary = [DefaultsKey.OpenedTheFirstTime.rawValue: true,								  DefaultsKey.CreationDate.rawValue: Date().timeIntervalSince1970,
		                  DefaultsKey.ChecklistsAdded.rawValue: 0,
		                  DefaultsKey.ChecklistsArchived.rawValue: 0,
		                  DefaultsKey.ItemsAdded.rawValue: 0,
		                  DefaultsKey.ItemsDone.rawValue: 0,
		                  DefaultsKey.ZoomLevel.rawValue: 9,
		                  DefaultsKey.Username.rawValue: "",
		                  DefaultsKey.Token.rawValue: "",
		                  DefaultsKey.TokenExpiration.rawValue: -1,
		                  DefaultsKey.Password.rawValue: "",
		                  DefaultsKey.LastChangeDate.rawValue: -1,
		                  DefaultsKey.ActualizationDate.rawValue: -1,
		                  DefaultsKey.InitialUserLoadChecklists.rawValue: false,
		                  DefaultsKey.InitialUserLoadItems.rawValue: false,
		                  DefaultsKey.TemporaryUsername.rawValue: temporaryUsername,
		                  DefaultsKey.UsernameIsTemporary.rawValue: true
		                  ] as [String : Any]
		UserDefaults.standard.register(defaults: dictionary as [String : AnyObject])

	}
	
	static func resetSyncedUserDefaults() {
		let defaults = [
		DefaultsKey.LastChangeDate.rawValue: -1,
		DefaultsKey.ActualizationDate.rawValue: -1,
		DefaultsKey.InitialUserLoadChecklists.rawValue: false,
		DefaultsKey.InitialUserLoadItems.rawValue: false,
		DefaultsKey.UsernameIsTemporary.rawValue: true,
		DefaultsKey.Token.rawValue: "null",
		DefaultsKey.TokenExpiration.rawValue: -1
		] as [String : Any]
		
		UserDefaults.standard.setValuesForKeys(defaults)
		
	}
	
	static func setFirstOpenedTime() {
		if UserDefaults.standard.bool(forKey: DefaultsKey.OpenedTheFirstTime.rawValue) {
			UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: DefaultsKey.CreationDate.rawValue)
			let temporaryUsername = DefaultsHelper.getDefaultByKey(.TemporaryUsername) as! String
			UserDefaults.standard.set(temporaryUsername, forKey: DefaultsKey.TemporaryUsername.rawValue)
		}
		UserDefaults.standard.set(false, forKey: DefaultsKey.OpenedTheFirstTime.rawValue)
	}
	
	// ob]edinit
	static func addChecklist() {
		let checklistsAddedCount = UserDefaults.standard.integer(forKey: DefaultsKey.ChecklistsAdded.rawValue)
		UserDefaults.standard.set(checklistsAddedCount + 1, forKey: DefaultsKey.ChecklistsAdded.rawValue)
//		incrementAllItemsCount()
	}
	
	static func addItem() {
		let ItemsAddedCount = UserDefaults.standard.integer(forKey: DefaultsKey.ItemsAdded.rawValue)
		UserDefaults.standard.set(ItemsAddedCount + 1, forKey: DefaultsKey.ItemsAdded.rawValue)
//	    incrementAllItemsCount()
	}
	
	static func setLastChangeDate(_ date: Double = Date().timeIntervalSince1970) {
		UserDefaults.standard.set(date, forKey: DefaultsKey.LastChangeDate.rawValue)
	}
	
	static func getLastChangeDate() -> Double {
		return UserDefaults.standard.double(forKey: DefaultsKey.LastChangeDate.rawValue)
	}
	
	
	
	static func getDefaultByKey(_ key: DefaultsKey) -> AnyObject {
		return UserDefaults.standard.object(forKey: key.rawValue)! as AnyObject
	}
	
	
	
	
	
	static func modifyDoneAdditive(_ additive: Bool) {
		let ItemsDoneCount = UserDefaults.standard.integer(forKey: DefaultsKey.ItemsDone.rawValue)
		let modificator = additive == true ? 1 : -1
		UserDefaults.standard.set(ItemsDoneCount + modificator, forKey: DefaultsKey.ItemsDone.rawValue)
	}
	
	static func setNewDefaultZoomLevel(_ level: Double) {
		UserDefaults.standard.set(level, forKey: DefaultsKey.ZoomLevel.rawValue)
	}
	
	static func getDefaultZoomLevel() -> Float {
		return Float(UserDefaults.standard.double(forKey: DefaultsKey.ZoomLevel.rawValue))
	}
	
//	static func getDefaultByKey(key: DefaultsKey) -> Int {
//		return NSUserDefaults.standardUserDefaults().integerForKey(key.rawValue)
//	}
	
	static func getStartingDate() -> Double {
		return UserDefaults.standard.double(forKey: DefaultsKey.CreationDate.rawValue)
	}
	
	static func setUsername(_ username: String) {
		UserDefaults.standard.set(username, forKey: DefaultsKey.Username.rawValue)
	}
	
	static func setTemporaryUsername(_ username: String) {
		UserDefaults.standard.set(username, forKey: DefaultsKey.TemporaryUsername.rawValue)
	}
	
	static func setToken(_ token: String) {
		UserDefaults.standard.set(token, forKey: DefaultsKey.Token.rawValue)
	}
	
	static func setTokenExpiration(_ tokenExpiration: Double) {
		let newExpirationTime = Date().timeIntervalSince1970 + tokenExpiration
		UserDefaults.standard.set(newExpirationTime, forKey: DefaultsKey.TokenExpiration.rawValue)
	}
	
	static func getToken() -> String {
		return UserDefaults.standard.object(forKey: DefaultsKey.Token.rawValue) as! String
	}
	
	static func getUsernameAndPassword() -> (String, String) {
		let username = UserDefaults.standard.object(forKey: DefaultsKey.Username.rawValue) as! String
		let password = UserDefaults.standard.object(forKey: DefaultsKey.Password.rawValue) as! String
		return (username, password)
	}
	
	static func getActualiztionDate() -> Double {
		return UserDefaults.standard.double(forKey: DefaultsKey.ActualizationDate.rawValue)
	}
	
	static func setPassword(_ password: String) {
		UserDefaults.standard.set(password, forKey: DefaultsKey.Password.rawValue)
	}
	
	static func setActualizationDate(_ actualizationDate: Double) {
		UserDefaults.standard.set(actualizationDate, forKey: DefaultsKey.ActualizationDate.rawValue)
	}
	
	static func getInitialUserLoad() -> ((Bool, Bool)) {
		return (UserDefaults.standard.bool(forKey: DefaultsKey.InitialUserLoadChecklists.rawValue),
			UserDefaults.standard.bool(forKey: DefaultsKey.InitialUserLoadItems.rawValue))
	}
	
	static func setInitialUserLoadChecklist(_ state: Bool) {
		UserDefaults.standard.set(state, forKey: DefaultsKey.InitialUserLoadChecklists.rawValue)
	}
	
	static func setInitialUserLoadItems(_ state: Bool) {
		UserDefaults.standard.set(state, forKey: DefaultsKey.InitialUserLoadItems.rawValue)
	}
	
	// Sets the defaults up as user has logged in and now has valid and legitimate
	static func setPersistentUsername(_ username: String) {
		UserDefaults.standard.set(username, forKey: DefaultsKey.Username.rawValue)
		UserDefaults.standard.set(false, forKey: DefaultsKey.UsernameIsTemporary.rawValue)
	}
	
	// checkls if user has a persistent server approved username. Otherwise returns temporary
	static func getUsername() -> String {
		if DefaultsHelper.getDefaultByKey(.UsernameIsTemporary) as! Bool {
			return DefaultsHelper.getDefaultByKey(.TemporaryUsername) as! String
		}
		return DefaultsHelper.getDefaultByKey(.Username) as! String
	}
	
}
