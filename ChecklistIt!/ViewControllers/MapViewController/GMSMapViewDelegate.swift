//
//  MapViewControllerGoogleMap.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 22.12.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import GoogleMaps


extension MapViewController: GMSMapViewDelegate {
	func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
		if markerToAdd != nil {
			markerToAdd!.map = nil
			markerToAdd = nil
			
			mapAddButtons.hideAddButtons()
		} else {
			markerToAdd = GMSMarker(position: coordinate)
//			markerToAdd!.title = "Add new checklist or item"
			markerToAdd!.map = mapView
			mapView.selectedMarker = markerToAdd
		}
	}
	
	func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
		// sets camera at the initial position when opened the first time
		guard viewWasOpened else {
			return
		}
		showAllMarkers()
		viewWasOpened = false
	}
	
	
	func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
		DefaultsHelper.setNewDefaultZoomLevel(Double(position.zoom))
	}
	
	func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
		if marker == markerToAdd {
//			let infoView = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height: 44))
//			let text = "Add checklist or item!"
//			let checklistRange = (text as NSString).rangeOfString("checklist")
//			let itemRange = (text as NSString).rangeOfString("item")
//			let attributedString = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14)])
//			attributedString.setAttributes([NSForegroundColorAttributeName : ResourceManager.getColor(.NavBarColor)], range: checklistRange)
//			attributedString.setAttributes([NSForegroundColorAttributeName : ResourceManager.getColor(.SecondaryColor)], range: itemRange)
//			showAddButtons()
//			infoView.attributedText = attributedString
//			return infoView
			
			showAddButtons()
			return nil
		}
		
		if let _ = markerToAdd {
			clearMarkerToAdd()
		}
		return nil
	}
}
