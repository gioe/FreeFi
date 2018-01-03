//
//  ViewController.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/1/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SwiftSpinner
import GooglePlaces

class MapViewController: UIViewController {
    
    enum Permission {
        case allowed
        case denied
    }
    
    var submissionDelegate: Submittable?
    fileprivate let identifier = "Pin"
    private let searchController = UISearchController(searchResultsController: nil)
    private var viewModel = SpotsViewModel()
    private var mapView: MKMapView!
    private var locationManager = CLLocationManager()
    private var mapPermission: Permission = .denied {
        didSet {
            switch mapPermission {
            case .allowed:
                setupMapViews()
            case .denied:
                setupPermissionViews()
            }
        }
    }

    private var currentLocation: CLLocation? {
        didSet {
            determineZipcode()
        }
    }
    
    private var closestLocations: [Spot] = [] {
        didSet {
            addAnnotations()
        }
    }
    
    private var currentZipCode: String = "" {
        didSet {
            lookupSpotsAtZipcode(currentZipCode)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated:true)
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupLocationManager() {
        switch CLLocationManager.authorizationStatus() {
        default:
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    private func setupPermissionViews() {
       view = PermissionView()
    }
        
    private func setupMapViews() {
    
        mapView = MKMapView()
        mapView.mapType = .standard
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        [mapView].forEach{
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    func setupConstraints() {
        switch mapPermission {
        case .allowed:
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        default:
           break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addAnnotations() {
        closestLocations.forEach{
            let annotation = MKPointAnnotation()
            annotation.subtitle = $0.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            let key = String(describing: annotation.coordinate)
            AnnotationRegistry.shared.registryDict[key] = $0
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation) //Yes!! This method adds the annotations
            }
        }
        SwiftSpinner.hide()
    }
    
    private func determineZipcode() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        viewModel.deriveZipcodeFrom(location: currentLocation) { (zipCode, error) in
            guard error == nil, let zipCode = zipCode else {
                return
            }
            self.currentZipCode = zipCode
        }
    }
    
    private func lookupSpotsAtZipcode(_ zipCode: String) {
        SwiftSpinner.show("Fetching spots...")
        viewModel.getNearbySpots(zipCode: zipCode) {
            self.closestLocations = $0
        }
    }
    
    public func moveMapToLocation(location: CLLocationCoordinate2D, zipCode: String) {
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        lookupSpotsAtZipcode(zipCode)
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapPermission = .allowed
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            SwiftSpinner.show("Locating spots...")
        case .denied:
            mapPermission = .denied
        default:
            break
        }
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard !locations.isEmpty, let firstLocation = locations.first else { return }
        locationManager.stopUpdatingLocation()
        currentLocation = firstLocation
        let center = CLLocationCoordinate2D.init(latitude: firstLocation.coordinate.latitude, longitude: firstLocation.coordinate.longitude)
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center:center, span: span)
        mapView.setRegion(region, animated: true)
        SwiftSpinner.hide()
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        guard !views.isEmpty else {
            return
        }
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pin?.canShowCallout = true
        } else {
            pin?.annotation = annotation
        }
        
        let accessoryView = AnnotationAccessoryView(annotation: annotation)
        accessoryView.selectionDelegate = self
        pin?.detailCalloutAccessoryView = accessoryView
        
        return pin
    }

}

extension MapViewController: Refreshable {
    
    public func refreshData() {
        guard CLLocationManager.authorizationStatus() != .denied else {
            return
        }
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(mapView.annotations)
        }
        closestLocations.removeAll()
        locationManager.startUpdatingLocation()
    }
    
}

extension MapViewController: CalloutSelectionDelegate {
    
    func clickedCallout(for annotation: MKAnnotation) {
      
        let coordinateString = String(describing: annotation.coordinate)
      
        guard let spot = AnnotationRegistry.shared.registryDict[coordinateString] else {
            return
        }
      
        let currentSpot = SpotDetailViewController(type: .existing(spot: spot))
        currentSpot.submissionDelegate = self.submissionDelegate
        navigationController?.pushViewController(currentSpot, animated: true)
        mapView.deselectAnnotation(annotation, animated: true)
    }
    
}
