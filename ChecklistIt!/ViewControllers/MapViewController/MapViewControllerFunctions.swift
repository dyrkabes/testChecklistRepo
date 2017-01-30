//
//  Markers.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 22.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import GoogleMaps


extension MapViewController {
	func showAllMarkers() {
		let camera: GMSCameraPosition
		let zoom = DefaultsHelper.getDefaultZoomLevel()
		
		var markersOnMap: [GMSMarker] = []
		
		for marker in markers {
			if shouldBeShown(marker) {
				markersOnMap.append(marker)
			}
		}
		if markersOnMap.count == 0 {
			// it is nil after loading but it is not overall. Probably delegate (like found users location and refresh then
			// or some type of did set did change
			// or _ = myLocation at did load
			
			if let userLocation = mapView.myLocation {
				camera = GMSCameraPosition(target: userLocation.coordinate, zoom: zoom, bearing: 0, viewingAngle: 0)
			} else {
				camera = GMSCameraPosition(target: CLLocationCoordinate2DMake(47.235, 38.895), zoom: zoom, bearing: 0, viewingAngle: 0)
			}
			mapView.animate(to: camera)
			
		} else if markersOnMap.count == 1 {
			camera = GMSCameraPosition(target: (markersOnMap[0].userData as! BaseItem).getEntityLocation(), zoom: zoom, bearing: 0, viewingAngle: 0)
			mapView.animate(to: camera)
			
		} else {
			let path: GMSMutablePath = GMSMutablePath()
			for marker in markersOnMap {
				path.add((marker.userData as! BaseItem).getEntityLocation())
			}
			var coordinateBounds = GMSCoordinateBounds()
			for marker in markersOnMap {
				coordinateBounds = coordinateBounds.includingCoordinate((marker.userData as! BaseItem).getEntityLocation())
				
			}
			camera = GMSCameraPosition()
			let cameraUpdate = GMSCameraUpdate.fit(coordinateBounds)
			mapView.animate(with: cameraUpdate)
		}
	}
	
	func placeMarkers() {
		for marker in markers {
			if shouldBeShown(marker) {
				marker.map = mapView
			} else {
				marker.map = nil
			}
		}
	}
	
	func shouldBeShown(_ marker: GMSMarker) -> Bool {
		if let checklist = marker.userData as? Checklist {
			if mapViewControllerHelper.filteredChecklists.contains(checklist) {
				return false
			} else {
				return true
			}
		}
		if let item = marker.userData as? Item {
			if mapViewControllerHelper.filteredChecklists.contains(item.checklist) {
				return false
			} else {
				if hideDone && item.done == 1 {
					return false
				} else {
					return true
				}
			}
		}
		return false
	}
	
	func toggleHideDone() {
		hideDone = !hideDone
		placeMarkers()
	}
	
	
}
