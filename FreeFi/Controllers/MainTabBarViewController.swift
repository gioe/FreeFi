//
//  MainTabBarViewController.swift
//  FreeFi
//
//  Created by Matt on 12/8/17.
//  Copyright © 2017 Matt. All rights reserved.
//

import UIKit
import GooglePlaces

public protocol Submittable {
    func submittedForm()
}

public protocol Refreshable {
    func refreshData()
}

class MainTabBarViewController: UITabBarController {
    
    public var refreshDelegate: Refreshable?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupViewControllers()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView () {
        navigationItem.title = "FreeFi"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "refresh"), style: .done, target: self, action: #selector(refreshData))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "search"), style: .done, target: self, action: #selector(pushSearch))

        delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupViewControllers() {
        let mapView = MapViewController()
        mapView.view.backgroundColor = .white
        refreshDelegate = mapView
        mapView.tabBarItem = UITabBarItem(title: "Current Spot", image: #imageLiteral(resourceName: "pin"), selectedImage: #imageLiteral(resourceName: "pin"))
        
        let spotDetailView = SpotDetailViewController(type: .empty)
        spotDetailView.submissionDelegate = self
        spotDetailView.tabBarItem = UITabBarItem(title: "Add Spot", image: #imageLiteral(resourceName: "add"), selectedImage: #imageLiteral(resourceName: "add"))
        
        viewControllers = [mapView, spotDetailView]
    }

    @objc private func refreshData() {
        refreshDelegate?.refreshData()
    }
    
    @objc fileprivate func getCurrentAddress() {
        
        LocationManager.shared.getCurrentPlace { (place, error) in
            guard error == nil, let place = place else {
                return
            }
            if let viewControllers = self.viewControllers, let spotVc = viewControllers[1] as? SpotDetailViewController {
                spotVc.addressForm.injectPlaceIntoForm(place: place)
            }
        }
        
    }
    
    @objc private func pushSearch() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Set a filter to return only addresses.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
}

extension MainTabBarViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        if let addressLines = place.addressComponents {
            // Populate all of the address fields we can find.
            for field in addressLines {
                switch field.type {
                case kGMSPlaceTypePostalCode:
                    if let viewControllers = viewControllers, let mapVc = viewControllers[0] as? MapViewController {
                        mapVc.moveMapToLocation(location: place.coordinate, zipCode: field.name)
                    }
                default:
                    print("Type: \(field.type), Name: \(field.name)")
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    

}

extension MainTabBarViewController: Submittable {
    public func submittedForm() {
        if let viewControllers = viewControllers, let mapVc = viewControllers[0] as? MapViewController {
           self.selectedViewController = mapVc
        }
    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch viewController {
        case let spotVc as SpotDetailViewController:
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "pin"), style: .done, target: self, action: #selector(getCurrentAddress))
            navigationItem.rightBarButtonItem = nil
            spotVc.addressForm.refreshForm()
        case let mapVc as MapViewController:
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "search"), style: .done, target: self, action: #selector(pushSearch))
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "refresh"), style: .done, target: self, action: #selector(refreshData))
            mapVc.refreshData()
        default: break
        }
        
    }
    
}

