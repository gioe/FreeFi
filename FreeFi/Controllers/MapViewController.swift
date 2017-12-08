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
    
    fileprivate let identifier = "Pin"
    fileprivate var currentZipCode: String = ""
    private let searchController = UISearchController(searchResultsController: nil)
    private var viewModel = SpotsViewModel()
    private var mapView: MKMapView!
    private var locationManager = CLLocationManager()
    private var geocoder = CLGeocoder()
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

    private let permissionsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Adjust Permissions", for: .normal)
        button.addTarget(self, action: #selector(pushPermissionView), for: .touchUpInside)
        return button
    }()
    
    let resultsTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isHidden = true
        return table
    }()
    
    private var currentLocation: CLLocation? {
        didSet {
            determineZipcode()
        }
    }
    
    private var searchedLocations: [Spot] = [] {
        didSet {
            resultsTable.reloadData()
        }
    }
    
    private var closestLocations: [Spot] = [] {
        didSet {
            addAnnotations()
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
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            mapPermission = .allowed
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            SwiftSpinner.show("Locating spots...")
        case .denied:
            mapPermission = .denied
        default:
            break
        }
    }
    
    private func setupPermissionViews() {
        
        [permissionsButton].forEach{
            view.addSubview($0)
        }
        
        setupConstraints()

    }
        
    private func setupMapViews() {
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "FreeFi"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "add"), style: .done, target: self, action: #selector(addNewSpot))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "refresh"), style: .done, target: self, action: #selector(refreshMap))
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search For Address"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.delegate = self
        
        mapView = MKMapView()
        mapView.mapType = .standard
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        resultsTable.dataSource = self
        
        [mapView, resultsTable].forEach{
            view.addSubview($0)
        }
        
        setupConstraints()

    }
    
    func setupConstraints() {
        
        resultsTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        resultsTable.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        resultsTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        resultsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc private func addNewSpot() {
        guard let location = currentLocation else {
            return
        }
        
        let spotVc = SpotDetailViewController(type: .new(location: location))
        spotVc.view.backgroundColor = .white
        navigationController?.pushViewController(spotVc, animated: true)
    }
    
    @objc private func refreshMap() {
        closestLocations.removeAll()

        self.lookupSpotsAtZipcode(currentZipCode)

    }
    
    @objc private func pushPermissionView() {
        
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
            AnnotationRegistry.shared.registryDict[$0.name ?? ""] = $0
            mapView.addAnnotation(annotation)
        }
    }
    
    private func determineZipcode() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            guard error == nil, let placemarks = placemarks, let firstPlacemark = placemarks.first, let zipCode = firstPlacemark.postalCode else {
                return
            }
            
            self.currentZipCode = zipCode
            
            self.lookupSpotsAtZipcode(zipCode)
        }
        
    }
    
    private func lookupSpotsAtZipcode(_ zipCode: String) {
        self.viewModel.getNearbySpots(zipCode: zipCode) {
            self.closestLocations = $0
        }
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard !locations.isEmpty, let firstLocation = locations.first else { return }
        locationManager.stopUpdatingLocation()
        currentLocation = firstLocation
        
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
        
        SwiftSpinner.hide()
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
    
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Print place info to the console.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        
        if let addressLines = place.addressComponents {
            // Populate all of the address fields we can find.
            for field in addressLines {
                switch field.type {
                case kGMSPlaceTypePostalCode:
                    mapView.centerCoordinate = place.coordinate
                    currentZipCode = field.name
                    refreshMap()
                default:
                    print("Type: \(field.type), Name: \(field.name)")
                }
            }
        }
        
        // Close the autocomplete widget.
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Show the network activity indicator.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    // Hide the network activity indicator.
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension MapViewController: UISearchBarDelegate {
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Set a filter to return only addresses.
        let addressFilter = GMSAutocompleteFilter()
        addressFilter.type = .address
        autocompleteController.autocompleteFilter = addressFilter
        
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        resultsTable.isHidden = true
        mapView.isHidden = false
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}

extension MapViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension MapViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !searchedLocations.isEmpty else {
            return 0
        }
        return searchedLocations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard !searchedLocations.isEmpty else {
            return UITableViewCell()
        }
        let cell = UITableViewCell()
        return cell
    }
    
}

extension MapViewController: CalloutSelectionDelegate {
    
    func clickedCallout(for annotation: MKAnnotation) {
        
        guard let subtitle = annotation.subtitle, let subtitleText = subtitle,  let spot = AnnotationRegistry.shared.registryDict[subtitleText] else {
            return
        }
        
        let currentSpot = SpotDetailViewController(type: .existing(spot: spot))
        currentSpot.view.backgroundColor = .white
        navigationController?.pushViewController(currentSpot, animated: true)
        mapView.deselectAnnotation(annotation, animated: true)
    }
    
}


