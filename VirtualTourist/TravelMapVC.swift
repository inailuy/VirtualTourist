//
//  TravelMapVC.swift
//  VirtualTourist
//
//  Created by inailuy on 4/19/16.
//  Copyright © 2016 Udacity. All rights reserved.
//
import MapKit

class TravelMapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var deletePinLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var annotationArray = NSMutableArray()
    var deletePinState = false
    var selectedPin : Pin!
    var pinArray = [Pin]()
    
    let DONE = "Done"
    let EDIT = "Edit"
    let photoSegue = "photoSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DatabaseWorker.sharedInstance.fetchAllPin({ (array: NSArray) in
            self.pinArray = array as! [Pin]
            for pin in array as! [Pin] {
                let annotation = MKPointAnnotation()
                annotation.coordinate = pin.coordinate()
                self.mapView.addAnnotation(annotation)
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == photoSegue {
            let vc = segue.destinationViewController as! PhotoAlbumVC
            vc.selectedCoordinate = selectedPin.coordinate()
            vc.selectedPin = selectedPin
            if selectedPin.photosInPin?.allObjects.count == 0 {
                let getModel = FlickerGetModel(coor: selectedPin.coordinate())
                DownloadWorker.sharedInstance.getPhotosWithLocation(getModel, pin: selectedPin, loadImageData: false, completion:  {_ in })
            } else {
                let vc = segue.destinationViewController as! PhotoAlbumVC
                let array = selectedPin.photosInPin!.allObjects
                vc.photoArray = NSMutableArray(array: array)
            }
        }
    }
    //MARK: Interactions
    @IBAction func longPressedGesture(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended && deletePinState == false {
            let touchPoint = sender.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            mapView.addAnnotation(annotation)
            let getModel = FlickerGetModel(coor: newCoordinates)
            let pin = DatabaseWorker.sharedInstance.createAndSavePin(newCoordinates)
            pinArray.append(pin)
            
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                DownloadWorker.sharedInstance.getPhotosWithLocation(getModel, pin: pin, loadImageData: true, completion: {_ in })
            }
        }
    }
    
    @IBAction func barButtonPressed(sender: UIBarButtonItem) {
        deleteLabelAnimation(!deletePinState)
        if deletePinState == true {
            sender.title = DONE
        } else {
            sender.title = EDIT
        }
    }
    
    func deleteLabelAnimation(state:Bool) {
        var labelFrame = deletePinLabel.frame
        var mapFrame = mapView.frame
        
        if state == true {
            labelFrame.origin.y = mapView.frame.size.height - deletePinLabel.frame.size.height
            mapFrame.size.height = mapFrame.size.height - labelFrame.size.height
        } else {
            labelFrame.origin.y = view.frame.size.height
            mapFrame = view.frame
        }
        
        UIView.animateWithDuration(0.2, animations: {
            self.deletePinLabel.frame = labelFrame
            self.mapView.frame = mapFrame
        })
        deletePinState = state
    }
    //MARK: MapView Delegate
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if deletePinState == false {
            let viewCoor = view.annotation?.coordinate
            for pin in pinArray as [Pin] {
                let pinCoor = pin.coordinate()
                if pinCoor.latitude == viewCoor?.latitude && pinCoor.longitude == viewCoor?.longitude {
                    selectedPin = pin
                    performSegueWithIdentifier(photoSegue, sender: nil)
                }
            }
        } else {
            for pin in pinArray {
                let pinCoor = pin.coordinate()
                let viewCoor = view.annotation?.coordinate
                if pinCoor.latitude == viewCoor?.latitude && pinCoor.longitude == viewCoor?.longitude {
                    DatabaseWorker.sharedInstance.deletePinAndPhotos(pin)
                    pinArray.removeAtIndex(pinArray.indexOf(pin)!)
                }
            }
            mapView.removeAnnotation(view.annotation!)
        }
    }
}