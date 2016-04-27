//
//  DatabaseWorker.swift
//  VirtualTourist
//
//  Created by inailuy on 4/20/16.
//  Copyright © 2016 Udacity. All rights reserved.
//
//
import CoreData
import UIKit
import CoreLocation

class DatabaseWorker {
    static let sharedInstance = DatabaseWorker()
    
    func fetchAllPin(completion: (array: NSArray) -> Void) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            let pins = results as! [Pin]
            completion(array: pins)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    //MARK: Creating
    func createAndSavePin(coordinate: CLLocationCoordinate2D) -> Pin {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let pin = NSEntityDescription.insertNewObjectForEntityForName("Pin", inManagedObjectContext: managedContext) as! Pin
        pin.addCoordinates(coordinate)
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        return pin
    }
    
    func createAndSavePhoto(dict: NSDictionary, pin: Pin) -> Photo {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: managedContext) as! Photo
        photo.populatePhoto(fromDict: dict)
        photo.belongsToPin = pin
        return photo
    }
    //MARK: Deleting
    func deletePinAndPhotos(pin: Pin) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // Delete photos related to pin
        deleteAllPhotosInPin(pin, shouldSave: false)
        appDelegate.managedObjectContext.deleteObject(pin)
        do {
            try appDelegate.managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllPhotosInPin(pin: Pin, shouldSave: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if pin.photosInPin?.count > 0 {
            for photo in pin.photosInPin?.allObjects as! [Photo] {
                deletePhotoFromDirectory(photo)
                appDelegate.managedObjectContext.deleteObject(photo)
            }
        }
        if shouldSave {
            do {
                try appDelegate.managedObjectContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    func deletePhoto(photo: Photo) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        deletePhotoFromDirectory(photo)
        appDelegate.managedObjectContext.deleteObject(photo)
        do {
            try appDelegate.managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    // Deleting from directory
    func deletePhotoFromDirectory(photo: Photo) {
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtPath(photo.imageFilePath())
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
}