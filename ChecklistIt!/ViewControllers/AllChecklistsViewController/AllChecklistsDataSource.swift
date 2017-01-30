//
//  AllChecklistsDataSource.swift
//  ChecklistIt
//
//  Created by Pavel Stepanov on 29/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import UIKit
// TODO: protocol
class AllChecklistsDataSource: NSObject, AllChecklistsDataSourceProtocol {
    var checklists = [Checklist]()
    var tableViewOwner: HasTableView!
    
    func fetchChecklists() {
        checklists = ManagedObjectContext.fetch(Checklist.self)
    }
    
    func getChecklists() -> [Checklist] {
        return checklists
    }
}

extension AllChecklistsDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return checklists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistCell", for: indexPath)
        cell.imageView?.image = ResourceManager.getImageWithCategory(checklists[indexPath.row].category)
        cell.textLabel?.text = checklists[indexPath.row].name
        cell.detailTextLabel?.text = checklists[indexPath.row].getItemsDoneString()
        ColorConfigurator.configureRegularCell(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        ManagedObjectContext.deleteEntity(checklists[indexPath.row])
        
        checklists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .middle)
        if checklists.count == 0 {
            tableView.reloadData()
        }
    }

}

