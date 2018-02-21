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

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var MapView: MKMapView!
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        
    }
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        MapView.addGestureRecognizer(doubleTap)
    }
    @IBAction func CenterMapbtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            
        }
    }
}
    extension MapVC: MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation{
                return nil
            }
            let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            pinAnnotation.pinTintColor = #colorLiteral(red: 0.9215686275, green: 0.7803921569, blue: 0.6156862745, alpha: 1)
            pinAnnotation.animatesDrop = true
            return pinAnnotation
        }
        
        func centerMapOnUserLocation() {
            guard let coordinate = locationManager.location?.coordinate else { return }
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
            MapView.setRegion(coordinateRegion, animated: true)
        }
        @objc func dropPin(sender: UITapGestureRecognizer) {
            removePin()
    let touchPoint = sender.location(in: MapView)
    let touchCoordinate = MapView.convert(touchPoint, toCoordinateFrom: MapView)
    let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
            MapView.addAnnotation(annotation)
            
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
            MapView.setRegion(coordinateRegion, animated: true)
    
        }
        func removePin() {
            for annotation in MapView.annotations {
                MapView.removeAnnotation(annotation)
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
