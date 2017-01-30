//
//  ChecklistDataSourceProtocol.swift
//  ChecklistIt
//
//  Created by Pavel Stepanov on 30/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//
import UIKit

protocol ChecklistDataSourceProtocol: UITableViewDataSource {
    func fetchItems()
    func getItems() -> [Item]
    func getCurrentChecklist() -> Checklist
    func setCurrentChecklist(currentChecklist: Checklist)
    func removeItem(at: Int)
}
