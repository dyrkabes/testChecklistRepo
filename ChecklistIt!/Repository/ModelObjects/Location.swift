//
//  Location.swift
//  ChecklistIt!
//
//  Created by Pavel Stepanov on 26.10.16.
//  Copyright © 2016 Pavel Stepanov. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Location: NSManagedObject {
	func locationCoordinate2DMake() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2DMake(latitude as Double, longitude as Double)
	}

// Insert code here to add functionality to your managed object subclass

}
