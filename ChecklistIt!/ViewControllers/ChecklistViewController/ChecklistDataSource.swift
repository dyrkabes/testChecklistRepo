//
//  ChecklistDataSource.swift
//  ChecklistIt
//
//  Created by Pavel Stepanov on 30/01/2017.
//  Copyright © 2017 Pavel Stepanov. All rights reserved.
//

import UIKit

class ChecklistDataSource: NSObject, ChecklistDataSourceProtocol {
    var items = [Item]()
    var currentChecklist: Checklist!
    
    
    func fetchItems() {
        items = ManagedObjectContext.fetchItemsForChecklist(currentChecklist)!
    }
    
    func getItems() -> [Item] {
        return items
    }
    
    func getCurrentChecklist() -> Checklist {
        return currentChecklist
    }
    
    func setCurrentChecklist(currentChecklist: Checklist) {
        self.currentChecklist = currentChecklist
    }
    
    func removeItem(at at: Int) {
        items.remove(at: at)
    }
}

extension ChecklistDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItemCell", for: indexPath) as! ChecklistItemCell
        cell.accessoryType = .detailButton
        cell.nameTextField!.text = items[indexPath.row].name
        cell.descriptionTextField!.text = items[indexPath.row].descriptionText
        
        //TODO: separate method
        let image = ResourceManager.getImageWithCategory("Checkmark")
        cell.doneImageView.image = image
        cell.doneImageView.isHidden = true
        if items[indexPath.row].done != 0 {
            cell.doneImageView.isHidden = false
        }
        
        ColorConfigurator.configureRegularCell(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        currentChecklist.itemsOverall = (currentChecklist.itemsOverall as Int - 1) as NSNumber
        if items[indexPath.row].done == 1 {
            currentChecklist.itemsDone = (currentChecklist.itemsDone as Int - 1) as NSNumber
        }
        
        ManagedObjectContext.deleteEntity(items[indexPath.row])
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .middle)
        if items.count == 0 {
            tableView.reloadData()
        }
        ManagedObjectContext.save()
    }
}
