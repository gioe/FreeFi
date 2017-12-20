//
//  LocationManager.swift
//  FreeFi
//
//  Created by Matt on 12/19/17.
//  Copyright © 2017 Matt. All rights reserved.
//

import Foundation
import CoreLocation
import GooglePlaces

public class LocationManager: NSObject {
    
    private var geocoder = CLGeocoder()
    private var placesClient = GMSPlacesClient.init()
    public static let shared = LocationManager()
    
    override private init() {
        super.init()
    }
    
    public func getCurrentPlace(completion: @escaping (GMSPlace?, Error?) -> Void) {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            guard error == nil, let placeLikelihoodList = placeLikelihoodList, let first = placeLikelihoodList.likelihoods.first else {
                completion(nil, error)
                return
            }
            completion(first.place, nil)
        })
    }
    
}
