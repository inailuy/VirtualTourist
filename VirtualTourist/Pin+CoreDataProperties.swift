//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by inailuy on 4/21/16.
//  Copyright © 2016 Udacity. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//
import CoreData
import CoreLocation

extension Pin {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var page: NSNumber?
    @NSManaged var photosInPin: NSSet?
    
    func addCoordinates(coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
    
    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude!.doubleValue, longitude: longitude!.doubleValue)
    }
}
