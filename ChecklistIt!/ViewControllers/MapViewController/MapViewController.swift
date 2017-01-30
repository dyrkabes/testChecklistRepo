//
//  MapViewController.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 26.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import GoogleMaps


import SnapKit

// TODO: Would be nice to add markers
// May be make a MVVM slice to pass chls and items to controllers - not showables do not appear in create checklist. Tho they shouldnt appear in filter

class MapViewController: UIViewController {
	// For user position 
	let locationManager = CLLocationManager()
	var mapView: GMSMapView!
	// If user wants to create a new marker and taps the map
	var markerToAdd: GMSMarker?
    // All markers got from database
	var markers = [GMSMarker]()
	// To hide done markers
	var hideDone = false
	// Initial camera set
	var viewWasOpened: Bool = true

	var mapViewControllerHelper = MapViewControllerHelper()

	var mapButtonsBar: MapButtonsBar!
	var mapAddButtons: MapAddButtons!


	override func viewDidLoad() {
		super.viewDidLoad()
		locationManager.delegate = self
		
		mapButtonsBar = MapButtonsBar(parentViewController: self)
		mapAddButtons = MapAddButtons(parentViewController: self)

	}
	

	// every time map view appears all constraints, markers are set;
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		mapView = ResourceManager.mapView
		

		setMapViewConstraints()
		
		
		mapView.clear()
		markers = []
		
		mapView.delegate = self
		
		let authStatus = CLLocationManager.authorizationStatus()
		if authStatus == .notDetermined {
			locationManager.requestWhenInUseAuthorization()
		}
		
		if authStatus == .denied {
			showLocationServiceDeniedAlert()
		}
		
		if authStatus == .authorizedWhenInUse {
			mapView.isMyLocationEnabled = true
			mapView.settings.myLocationButton = true
		}
		
		// all this stuff to MVVM i think
		var mapItems: [BaseItem] = []
		let checklists = ManagedObjectContext.fetch(Checklist.self)
		for checklist in checklists where checklist.isAbleToShow() {
			mapItems.append(checklist)
		}
		
		for item in ManagedObjectContext.fetch(Item.self) where item.isAbleToShow() {
			mapItems.append(item)
		}
		for mapItem in mapItems {
			addMarker(mapItem)
		}
		// bad name here
		placeMarkers()
		

		// info for selection and filter table view
		
		mapViewControllerHelper.setChecklistsForHelper(checklists)
		
		// to overlap mapView
		mapButtonsBar.bringToFront()
	}
	
	func setMapViewConstraints() {
		// clear map view constaints as it is reused
		mapView.removeConstraints(mapView.constraints)
		view.addSubview(mapView)
		// Configures controls' colors
		ColorConfigurator.configureViewController(self)
		
		// Constraints made with anchors. To fill all the view
		mapView.translatesAutoresizingMaskIntoConstraints = false
		mapView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
		let tabBarHeight = self.tabBarController?.tabBar.frame.height
		mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
		mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabBarHeight!).isActive = true
		mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		clearMarkerToAdd()
		mapView.removeFromSuperview()
	}
	
	func addMarker(_ item: BaseItem) {
		let marker = GMSMarker(position: item.getEntityLocation())
		
		let type: String
		if item is Checklist {
			type = "Checklist"
		} else {
			type = "Item"
		}
		
		//resursozatratno, redo loader
		marker.icon = ResourceManager.getFilteredImageForMapWithCategory(item.category, type: type)
		marker.title = item.name
		if item is Item {
			marker.snippet = (item as! Item).descriptionText
		}
		marker.userData = item
		markers.append(marker)
	}

	
	func showLocationServiceDeniedAlert() {
		let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable loc services for this app in Settings", preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
		alert.addAction(okAction)
		present(alert, animated: true, completion: nil)
	}
	
	// Filter button Tapped
	func showFilter() {
		mapViewControllerHelper.showSelectionTableView(self)
	}
	
	func showChecklistSelector() {
		mapViewControllerHelper.showSelectionTableView(self, filter: false)
	}
}


// MARK: - CLLOcationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			locationManager.startUpdatingLocation()
			
			mapView.isMyLocationEnabled = true
			mapView.settings.myLocationButton = true
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.first {
			let zoom = DefaultsHelper.getDefaultZoomLevel()
			mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: zoom, bearing: 0, viewingAngle: 0)
		}
		
		locationManager.stopUpdatingLocation()
	}
	

	func showAddViewController(_ button: UIButton!) {
		let navigationController = self.storyboard?.instantiateViewController(withIdentifier: "Add" + "Checklist" + "NavigationController") as! UINavigationController
		let addChecklistVC = navigationController.viewControllers[0] as! AddChecklistViewController
		
		let location: Location = ManagedObjectContext.insertEntity(Location.self) as! Location
		location.latitude = markerToAdd!.position.latitude as NSNumber
		location.longitude = markerToAdd!.position.longitude as NSNumber
		

		let checklist = ManagedObjectContext.insertEntity(Checklist.self) as! Checklist
		// TODO: Obv
		checklist.id = UUID().uuidString
		checklist.username = DefaultsHelper.getUsername()
		checklist.name = ""
		checklist.showOnMap = true
		checklist.itemsDone = 0
		checklist.itemsOverall = 0
		checklist.category = "No category"
		checklist.creationDate = Date().timeIntervalSince1970 as NSNumber
		checklist.location = location
		checklist.status = "normal"

		addChecklistVC.checklistToEdit = checklist
		addChecklistVC.currentCoordinate = CLLocationCoordinate2DMake(markerToAdd!.position.latitude, markerToAdd!.position.longitude)
		
		clearMarkerToAdd()
		
		present(navigationController, animated: true, completion: nil)
	}
	
	func showAddItemViewController(_ checklist: Checklist) {
		let navigationController = self.storyboard?.instantiateViewController(withIdentifier: "Add" + "Item" + "NavigationController") as! UINavigationController
		let addItemVC = navigationController.viewControllers[0] as! AddItemViewController
		
		let location: Location = ManagedObjectContext.insertEntity(Location.self) as! Location
		location.latitude = markerToAdd!.position.latitude as NSNumber
		location.longitude = markerToAdd!.position.longitude as NSNumber
		
		let item = ManagedObjectContext.insertEntity(Item.self) as! Item
		item.id = UUID().uuidString
		item.checklist = checklist
		item.username = DefaultsHelper.getUsername()
		item.descriptionText = ""
		item.done = 0
		item.name = ""
		item.showOnMap = true
		item.category = "No category"
		item.creationDate = Date().timeIntervalSince1970 as NSNumber
		item.location = location
		item.changeDate = Date().timeIntervalSince1970 as NSNumber
		item.status = "normal"
		
		addItemVC.itemToEdit = item
		
		addItemVC.currentCoordinate = CLLocationCoordinate2DMake(markerToAdd!.position.latitude, markerToAdd!.position.longitude)
		
		var itemsOverall = checklist.itemsOverall as Int
		itemsOverall += 1
		checklist.itemsOverall = itemsOverall as NSNumber
		
		clearMarkerToAdd()
		
		present(navigationController, animated: true, completion: nil)
	}
	
	func clearMarkerToAdd() {
		markerToAdd?.map = nil
		markerToAdd = nil

		mapAddButtons.hideAddButtons()
	}
	

	
	func showAddButtons() {
		mapAddButtons.showAddButtons()
	}

}

