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
    var selectedPin : Pin!
    var photoArray = NSMutableArray()
    var selectedCells = NSMutableArray()
    var selectedCoordinate : CLLocationCoordinate2D!

    override func viewDidLoad() {
        let region = MKCoordinateRegion(center: selectedCoordinate!, span: MKCoordinateSpanMake(0.6, 0.6))
        let adjustedRegion = mapView.regionThatFits(region)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedCoordinate!
        mapView.setRegion(adjustedRegion, animated: false)
        mapView.addAnnotation(annotation)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(photosUpdated),
            name: "UpdateForPhotoDownload",
            object: nil)
    }
    
    @IBAction func toolbarButtonPressed(sender: UIBarButtonItem) {
        if selectedCells.count > 0 {
            for index in selectedCells {
                if photoArray.count > index.row {
                    let photo = photoArray[index.row] as! Photo
                    DatabaseWorker.sharedInstance.deletePhoto(photo)
                    photoArray.removeObject(photo)
                }
            }
            collectionView.reloadData()
        } else {
            // Reload data
            photoArray.removeAllObjects()
            var getModel = FlickerGetModel(coor: (selectedPin?.coordinate())!)
            selectedPin?.page = NSNumber(int: (selectedPin!.page!.intValue) + 1)
            getModel.page = (selectedPin?.page?.integerValue)!
            DownloadWorker.sharedInstance.getPhotosWithLocation(getModel, pin: selectedPin!)
        }
        selectedCells.removeAllObjects()
        updateToolbarTitle()
    }
    //MARK: UICollectionView DataSource/Delegate
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("id", forIndexPath: indexPath)
        let imgView = cell.viewWithTag(100) as! UIImageView
        imgView.alpha = 1.0
        imgView.hidden = false
        let photo = photoArray[indexPath.row] as! Photo
        if photo.doesFileForImageExist() {
            imgView.image = UIImage.init(contentsOfFile:photo.imageFilePath())
        } else {
            imgView.hidden = true
            DownloadWorker.sharedInstance.getPhotoData(photo)
        }
        return cell
    }
    
    // check why images after being placed online and come back online arent being loaded when enter the view
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        let imgView = cell!.viewWithTag(100) as! UIImageView
        if selectedCells.containsObject(indexPath) {
            selectedCells.removeObject(indexPath)
            imgView.alpha = 1.0
        } else {
            selectedCells.addObject(indexPath)
            imgView.alpha = 0.3
        }
        updateToolbarTitle()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    //MARK: Misc
    func updateToolbarTitle() {
        var title = "New Collection"
        if selectedCells.count > 0 {
            title = "Remove Selected Pictures"
        }
        toolbarButton.title = title
    }
    
    @objc func photosUpdated(notification: NSNotification){
        if selectedPin.photosInPin?.allObjects.count > 0 && photoArray.count == 0 {
            let array = selectedPin.photosInPin!.allObjects
            photoArray = NSMutableArray(array: array)
        }
        
        self.collectionView.reloadData()
    }
}
