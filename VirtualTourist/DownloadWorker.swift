//
//  FlickerWorker.swift
//  VirtualTourist
//
//  Created by inailuy on 4/19/16.
//  Copyright © 2016 Udacity. All rights reserved.
//
// TODO: Change Class name to DownloadWorker
// flicker image downloader
// db helper
import Foundation
import CoreLocation

class FlickerWorker {
    let APIKey = "6707facd0b30adf08698009c1ba926e1"
    let APISecret = "b41afba30a99624a"
    
    let flickrURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
    
    
    static let sharedInstance = FlickerWorker()
    
    func createRequest(url: NSURL, method: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    func getPhotosWithLocation(location: CLLocationCoordinate2D) {
        let getModel = FlickerGetModel(coor: location)
        let request = createRequest(NSURL(string:flickrURL+getModel.methodString())!, method: "get")

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in            
            do {
                // ***Flicker JSON is wierd this helped http://stackoverflow.com/a/16187360/507299 ***
                
                //get the feed
                let badJSON = data
                //convert to UTF8 encoded string so that we can manipulate the 'badness' out of Flickr's feed
                var dataAsString = NSString(data: badJSON!, encoding: NSUTF8StringEncoding)! as String
                //remove the leading 'jsonFlickrFeed(' and trailing ')' from the response data so we are left with a dictionary root object
                dataAsString = dataAsString.stringByReplacingOccurrencesOfString("jsonFlickrApi(", withString: "")
                dataAsString = dataAsString.substringToIndex(dataAsString.endIndex.predecessor())
                var correctedJSONStr = dataAsString
                //Flickr incorrectly tries to escape single quotes - this is invalid JSON (see http://stackoverflow.com/a/2275428/423565)
                //correct by removing escape slash (note NSString also uses \ as escape character - thus we need to use \\)
                correctedJSONStr = correctedJSONStr.stringByReplacingOccurrencesOfString("\\'", withString: "'")
                //re-encode the now correct string representation of JSON back to a NSData object which can be parsed by NSJSONSerialization
                let correctedData = correctedJSONStr.dataUsingEncoding(NSUTF8StringEncoding)
                let json = try NSJSONSerialization.JSONObjectWithData(correctedData!, options: .AllowFragments)
                
                let dic = json["photos"] as! NSDictionary
                let arr = dic["photo"]
                photoArray.removeAll()
                for obj in arr as! NSArray {
                    let photo = FlickerPhotoModel(fromDict: obj as! NSDictionary)
                    photoArray.append(photo)
                }
                print(photoArray.count)
            }
            catch {}
        }
        task.resume()
    }
}