//
//  MapVC.swift
//  Pixel
//
//  Created by Yosadaq Esparza on 2/21/18.
//  Copyright © 2018 Y.M. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var PullupView: UIView!    
    @IBOutlet weak var PullupViewHt: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    var spinner: UIActivityIndicatorView?
    var progresslbl: UILabel?
    var screenSize = UIScreen.main.bounds
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var imageURLArray = [String]()
    var imageArray = [UIImage]()
    
    
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        
        PullupView.addSubview(collectionView!)
        
        registerForPreviewing(with: self, sourceView: collectionView!)
        
    }
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        MapView.addGestureRecognizer(doubleTap)
    }
    
    func addswipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        PullupView.addGestureRecognizer(swipe)
        
    }
    
    func animateViewUp() {
        PullupViewHt.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        cancelAllSessions()
        PullupViewHt.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgresslbl() {
        progresslbl = UILabel()
        progresslbl?.frame = CGRect(x: (screenSize.width / 2) - 100, y: 175, width: 200, height: 40)
        progresslbl?.font = UIFont(name: "Avenir", size: 21)
        progresslbl?.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        progresslbl?.textAlignment = .center
        collectionView?.addSubview(progresslbl!)
        
    }
    
    func removeProgresslbl() {
        if progresslbl != nil {
            progresslbl?.removeFromSuperview()
        }
    }
    
    
    @IBAction func CenterMapbtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
            
        }
    }
}
    extension MapVC: MKMapViewDelegate {
        func centerMapOnUserLocation() {
            guard let coordinate = locationManager.location?.coordinate else { return }
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
            MapView.setRegion(coordinateRegion, animated: true)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation{
                return nil
            }
            let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            pinAnnotation.pinTintColor = #colorLiteral(red: 0.9215686275, green: 0.7803921569, blue: 0.6156862745, alpha: 1)
            pinAnnotation.animatesDrop = true
            return pinAnnotation
        }
        @objc func dropPin(sender: UITapGestureRecognizer) {
            removePin()
            removeSpinner()
            removeProgresslbl()
            cancelAllSessions()
            
            imageURLArray = []
            imageArray = []
            
            collectionView?.reloadData()
            
            animateViewUp()
            addswipe()
            addSpinner()
            addProgresslbl()
            
            
    let touchPoint = sender.location(in: MapView)
    let touchCoordinate = MapView.convert(touchPoint, toCoordinateFrom: MapView)
    let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
            MapView.addAnnotation(annotation)
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
            MapView.setRegion(coordinateRegion, animated: true)
    
            retrieveUrls(forAnnotation: annotation) { (finished) in
                if finished {
                    self.retrieveImages(handler: { (finished) in
                        if finished {
                        self.removeSpinner()
                        self.removeProgresslbl()
                        self.collectionView?.reloadData()
                        }
                    })
                }
            }
        }
        func removePin() {
            for annotation in MapView.annotations {
                MapView.removeAnnotation(annotation)
            }
        }
        func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
            
            Alamofire.request(flickrURL(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 21)).responseJSON { (response) in
                guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
                let photosDict = json["photos"] as! Dictionary<String, AnyObject>
                let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
                for photo in photosDictArray {
                    let postURL = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                    self.imageURLArray.append(postURL)
                }
                handler(true)
            }
        }
        func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
            
            for url in imageURLArray {
                Alamofire.request(url).responseImage(completionHandler: { (response) in
                    guard let image = response.result.value else {return}
                    self.imageArray.append(image)
                    self.progresslbl?.text = "\(self.imageArray.count)/21 Images Downloaded"
                    
                    if self.imageArray.count == self.imageURLArray.count {
                        handler(true)
                    }
                })
            }
        }
        func cancelAllSessions() {
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
                sessionDataTask.forEach({ $0.cancel() })
                downloadData.forEach({ $0.cancel() })
            }
        }

    }
extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
        locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}
extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell() }
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return}
        popVC.initData(forImage: imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
    
}

extension MapVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return nil}
        
        popVC.initData(forImage: imageArray[indexPath.row])
        
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self )
    }
}

