//
//  AllChecklistsDataSourceProtocol.swift
//  ChecklistIt
//
//  Created by Pavel Stepanov on 29/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//
import UIKit

protocol AllChecklistsDataSourceProtocol: UITableViewDataSource {
    func fetchChecklists()
    func getChecklists() -> [Checklist]
}
