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
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}