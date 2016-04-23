//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by inailuy on 4/21/16.
//  Copyright © 2016 Udacity. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var farm: NSNumber?
    @NSManaged var owner: String?
    @NSManaged var photoId: String?
    @NSManaged var secrete: String?
    @NSManaged var server: String?
    @NSManaged var title: String?
    @NSManaged var belongsToPin: Pin?

    func populatePhoto(fromDict dict: NSDictionary) {
        photoId = dict["id"] as? String
        owner = dict["owner"] as? String
        secrete = dict["secret"] as? String
        server = dict["server"] as? String
        farm = dict["farm"] as? Int
        title = dict["title"] as? String
    }
    
    func imageURL() -> NSURL {
        //https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
        let farm = "https://farm"+self.farm!.stringValue
        let server = ".staticflickr.com/"+self.server!
        let id = "/"+self.photoId!+"_"
        let secrete = self.secrete!+"_s.jpg"
        let str = farm+server+id+secrete
        return NSURL(string: str)!
    }
    
    func imageFilePath() -> String {
        if photoId == nil { return "" }
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        return paths.firstObject as! String + "/" + photoId!
    }
    
    func doesFileForImageExist() -> Bool{
        var value = false
        let fileManager = NSFileManager.defaultManager()
        if (fileManager.fileExistsAtPath(imageFilePath())) {
            value = true
        }
        return value
    }
}
