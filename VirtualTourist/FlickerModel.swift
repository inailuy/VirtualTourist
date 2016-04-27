//
//  FlickerModel.swift
//  VirtualTourist
//
//  Created by inailuy on 4/19/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import CoreLocation

//var photoArray = [Photo]()

struct FlickerGetModel {
    let apiKey = "6707facd0b30adf08698009c1ba926e1"
    let coor : CLLocationCoordinate2D
    let accuracy = "11"
    let perPage = "12"
    var page = 1
    
    init (coor : CLLocationCoordinate2D){
        self.coor = coor
    }
    
    func objectToJSON() -> [String: AnyObject] {
        return [
            "api_key": apiKey,
            "lat": coor.latitude,
            "lon": coor.longitude,
            "accuracy": accuracy,
            "per_page": perPage,
            "page": page
        ]
    }
    
    func methodString() -> String {
        let and = "&"
        let key = "api_key="+apiKey+and
        let lat = "lat="+String(format:"%.1f", coor.latitude)+and
        let lon = "lon="+String(format:"%.1f", coor.longitude)+and
        let per = "per_page="+perPage+and
        let pag = "page="+String(page)+and
        let format = "format=json"
        return and+key+lat+lon+per+pag+format
    }
}

struct FlickerPhotoModel {
    let photoId: String
    let owner: String
    let secrete: String
    let server: String
    let farm: Int
    let title: String
    
    init(fromDict dict: NSDictionary) {
        self.photoId = dict["id"] as! String
        self.owner = dict["owner"] as! String
        self.secrete = dict["secret"] as! String
        self.server = dict["server"] as! String
        self.farm = dict["farm"] as! Int
        self.title = dict["title"] as! String
    }
    
    func imageURL() -> NSURL {
        //https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
        let str = "https://farm"+String(farm)+".staticflickr.com/"+server+"/"+photoId+"_"+secrete+".jpg"
        return NSURL(string: str)!
    }
}