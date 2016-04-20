//
//  TravelMapVC.swift
//  VirtualTourist
//
//  Created by inailuy on 4/19/16.
//  Copyright © 2016 Udacity. All rights reserved.
//
import UIKit
import MapKit

class TravelMapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var deletePinLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var annotationArray = NSMutableArray()
    var deletePinState = false
    var selectedCoordinate : CLLocationCoordinate2D!

    let DONE = "Done"
    let EDIT = "Edit"
    let photoSegue = "photoSegue"
    
    @IBAction func longPressedGesture(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended && deletePinState == false {
            let touchPoint = sender.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            mapView.addAnnotation(annotation)
            DownloadWorker.sharedInstance.getPhotosWithLocation(newCoordinates)
        }
    }
    //MARK: MapView Delegate
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if deletePinState == false {
            selectedCoordinate = view.annotation?.coordinate
            performSegueWithIdentifier(photoSegue, sender: nil)
        } else {
            mapView.removeAnnotation(view.annotation!)
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
        var labelFrame = self.deletePinLabel.frame
        var mapFrame = self.mapView.frame

        if state == true {
            labelFrame.origin.y = mapView.frame.size.height - deletePinLabel.frame.size.height
            mapFrame.size.height = mapFrame.size.height - labelFrame.size.height
        } else {
            labelFrame.origin.y = self.view.frame.size.height
            mapFrame = view.frame
        }
        
        UIView.animateWithDuration(0.2, animations: {
            self.deletePinLabel.frame = labelFrame
            self.mapView.frame = mapFrame
        })
        self.deletePinState = state
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == photoSegue {
            let vc = segue.destinationViewController as! PhotoAlbumVC
            vc.selectedCoordinate = selectedCoordinate
        }
    }
}