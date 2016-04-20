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
    var deletePinState = true
    
    @IBAction func longPressedGesture(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            let touchPoint = sender.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            mapView.addAnnotation(annotation)
            print(mapView.annotations.count)
        }
    }
    //MARK: MapView Delegate
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        performSegueWithIdentifier("photoSegue", sender: nil)
    }
    
    @IBAction func barButtonPressed(sender: AnyObject) {
        deleteLabelAnimation(!deletePinState)
    }
    
    func deleteLabelAnimation(state:Bool) {
        var frame = self.deletePinLabel.frame
        if state == true {
            frame.origin.y = self.mapView.frame.size.height - self.deletePinLabel.frame.size.height
        } else {
            frame.origin.y = self.view.frame.size.height
        }
        UIView.animateWithDuration(0.5, animations: {
            self.deletePinLabel.frame = frame
        })
        self.deletePinState = state
    }
    
}