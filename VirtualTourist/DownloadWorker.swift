//
//  FlickerWorker.swift
//  VirtualTourist
//
//  Created by inailuy on 4/19/16.
//  Copyright © 2016 Udacity. All rights reserved.
//
import CoreLocation
import UIKit

class DownloadWorker {
    let flickrURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
    static let sharedInstance = DownloadWorker()
    
    func createRequest(url: NSURL, method: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    func getPhotosWithLocation(getModel: FlickerGetModel, pin: Pin, loadImageData: Bool, completion:(photoArray: NSMutableArray) -> Void) {
        let request = createRequest(NSURL(string:flickrURL+getModel.methodString())!, method: "get")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in            
            do {
                if !self.hasConnectivity() {
                    return
                }
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
                let photoArr = dic["photo"]
                let completionArray = NSMutableArray()
                for obj in photoArr as! NSArray {
                    let photo = DatabaseWorker.sharedInstance.createAndSavePhoto(obj as! NSDictionary, pin: pin)
                    completionArray.addObject(photo)
                    if loadImageData == true {
                        DownloadWorker.sharedInstance.getPhotoData(photo, completion: { image in })
                    }
                }
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                do {
                    try appDelegate.managedObjectContext.save()
                    completion(photoArray: completionArray)
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
                
            }
            catch {}
        }
        task.resume()
    }
    
    func getPhotoData(photo: Photo, completion: (image: UIImage) -> Void) {
        if !hasConnectivity() {
            return
        }
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            if photo.doesFileForImageExist() == false {
                let url = photo.imageURL()
                let data = NSData(contentsOfURL: url)
                let docsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                if let image = UIImage(data: data!) {
                    let fileURL = docsURL.URLByAppendingPathComponent(photo.photoId!)
                    if let imageData = UIImagePNGRepresentation(image) {
                        imageData.writeToURL(fileURL, atomically: false)
                        completion(image: image)
                    }
                }
            }
        }
    }
    
    func hasConnectivity() -> Bool {
        let reachability: Reachability = Reachability.reachabilityForInternetConnection()
        let networkStatus: Int = reachability.currentReachabilityStatus().rawValue
        return networkStatus != 0
    }
}