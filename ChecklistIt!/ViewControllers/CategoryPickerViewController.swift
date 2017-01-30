//
//  CategoryPickerViewController.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 28.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
	let categories = ResourceManager.categories
	
	var selectedCategoryName = ""
	
	@IBAction func cancel() {
		_ = self.navigationController?.popViewController(animated: true)
	}
	
	override func viewDidLoad() {
		ColorConfigurator.configureViewController(self)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories.count
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		AppDelegate.networkStatusIcon.show(self)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
		cell.imageView?.image = ResourceManager.getImageWithCategory(categories[indexPath.row])
		cell.textLabel?.text = categories[indexPath.row]
		if selectedCategoryName == categories[indexPath.row] {
			
			let selectedView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 44))
			selectedView.backgroundColor = ResourceManager.getColor(.categoryPickerColor)
			cell.autoresizesSubviews = false
			cell.addSubview(selectedView)
        }
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		selectedCategoryName = categories[indexPath.row]
		let bgColorView = UIView()
		bgColorView.backgroundColor = ResourceManager.getColor(.navBarColor)
		let cell = tableView.cellForRow(at: indexPath)
		cell!.selectedBackgroundView = bgColorView
		
		return indexPath
	}
	
	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return ViewControllerHelper.showFooterOrPlug(self)
	}
}

extension CategoryPickerViewController: HasTableView {
	func getTableView() -> UITableView {
		return tableView
	}
}
