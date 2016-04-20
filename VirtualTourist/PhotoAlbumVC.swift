//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by inailuy on 4/19/16.
//  Copyright © 2016 Udacity. All rights reserved.
//
import UIKit
import MapKit

class PhotoAlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var toolbarButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    var selectedCells = NSMutableSet()
    var numCell = 10
    var selectedCoordinate : CLLocationCoordinate2D!

    override func viewDidLoad() {
        let region = MKCoordinateRegion(center: selectedCoordinate!, span: MKCoordinateSpanMake(0.6, 0.6))
        let adjustedRegion = mapView.regionThatFits(region)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedCoordinate!
        mapView.setRegion(adjustedRegion, animated: false)
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func toolbarButtonPressed(sender: UIBarButtonItem) {
        if selectedCells.count > 0 {
            numCell = numCell - selectedCells.allObjects.count
            collectionView.deleteItemsAtIndexPaths(selectedCells.allObjects as! [NSIndexPath])
        } else {
            // Reload data
            selectedCells.removeAllObjects()
            numCell = 10
            collectionView.reloadData()
        }
        
        selectedCells.removeAllObjects()
        updateToolbarTitle()
    }
    //MARK: UICollectionView DataSource/Delegate
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("id", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.blackColor()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if selectedCells.containsObject(indexPath) {
            selectedCells.removeObject(indexPath)
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            cell?.backgroundColor = UIColor.blackColor()
        } else {
            selectedCells.addObject(indexPath)
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            cell?.backgroundColor = UIColor.grayColor()
        }
        updateToolbarTitle()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numCell
    }
    //MARK: Misc
    func updateToolbarTitle() {
        var title = "New Collection"
        if selectedCells.count > 0 {
            title = "Remove Selected Pictures"
        }
        toolbarButton.title = title
    }
}
