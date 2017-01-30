//
//  MapCell.swift
//  ChecklistIt!
//
//  Created by Anastasia Stepanova-Kolupakhina on 26.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import UIKit
import GoogleMaps

class MapCell: UITableViewCell {
	var mapView: GMSMapView!
	// is used to select the place of base item
	var markerToChange: GMSMarker!
	// is used to move camera to the parent checklist's place on the map
	var checklistMarker: GMSMarker!
	// adding views
	var delegate: MapCellDelegate?
	
	var icon: UIImage!
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		initMapView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initMapView()
	}
	
	func initMapView() {
		mapView = ResourceManager.mapView
		mapView.clear()
		
		mapView.delegate = self
		self.contentView.addSubview(mapView)
		
		// constraints
		mapView.removeConstraints(mapView.constraints)
		mapView.translatesAutoresizingMaskIntoConstraints = false
		mapView.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
		mapView.heightAnchor.constraint(equalToConstant: contentView.frame.height).isActive = true
		mapView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		mapView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
	}
	
	func addMarkerWithBaseItem(baseItem: BaseItem) {
		// Adds editing item if there is one
		if markerToChange == nil {
			markerToChange = GMSMarker(position:
				CLLocationCoordinate2DMake(baseItem.location!.latitude as Double,
										   baseItem.location!.longitude as Double)
			)
		} else {
			markerToChange.position = CLLocationCoordinate2DMake(baseItem.location!.latitude as Double, baseItem.location!.longitude as Double)
		}
		
		markerToChange.map = mapView
		self.icon = ResourceManager.getFilteredImageForMapWithCategory(baseItem.category, type: baseItem.getType())
		markerToChange.icon = self.icon
		
		let zoomLevel = DefaultsHelper.getDefaultZoomLevel()
			
		mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition(target: markerToChange.position, zoom: zoomLevel, bearing: 0, viewingAngle: 0)))
	}
	
	func moveCameraToChecklistMarker() {
		let zoomLevel = DefaultsHelper.getDefaultZoomLevel()
		
		mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition(target: checklistMarker.position, zoom: zoomLevel, bearing: 0, viewingAngle: 0)))
	}
	
	func createChecklistMarker(checklist: Checklist) {
		checklistMarker = GMSMarker(position: checklist.location!.locationCoordinate2DMake())
		checklistMarker.icon = ResourceManager.getFilteredImageForMapWithCategory(checklist.category, type: "Checklist")
		checklistMarker.map = mapView
	}
	
	func setNewCategoryIcon(category: String, type: String) {
		if markerToChange == nil {
			markerToChange = GMSMarker()
		}
		icon = ResourceManager.getFilteredImageForMapWithCategory(category, type: type)
		markerToChange.icon = icon
		
	}
	
	func defaultCameraPosition() {
		// TODO: Rework
		let zoom = DefaultsHelper.getDefaultZoomLevel()
		let camera = GMSCameraPosition(target: CLLocationCoordinate2DMake(47.235, 38.895), zoom: zoom, bearing: 0, viewingAngle: 0)
		mapView.animate(to: camera)
	}
	
	
	func deinitMapView() {
		mapView.removeConstraints(mapView.constraints)
	}
	

}

extension MapCell: GMSMapViewDelegate {
	func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
		// create marker if if there's no marker
		if markerToChange == nil {
			markerToChange = GMSMarker(position: coordinate)
			
		} else {
			// move on tap
			markerToChange.position = coordinate
		}
		markerToChange.icon = icon
		markerToChange.map = mapView
		
		if let delegate = delegate {
			// writing new coordinates to the base item
			delegate.markerChangedPosition(markerToChange: markerToChange)
		}
	}
	
	func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
		DefaultsHelper.setNewDefaultZoomLevel(Double(position.zoom))
	}
}

protocol MapCellDelegate {
	func markerChangedPosition(markerToChange: GMSMarker)
}


