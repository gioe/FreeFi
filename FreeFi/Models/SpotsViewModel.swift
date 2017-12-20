//
//  SpotsViewModel.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/2/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import Foundation
import CoreLocation

public class SpotsViewModel: NSObject {
    
    private var geocoder = CLGeocoder()

    override public init() {
        super.init()
    }
    
    func getNearbySpots(zipCode: String, completion: @escaping ([Spot]) -> ()) {
        SpotsService.sharedInstance.getNearbySpots(zipCode) { (spots, _, _) in
            if let spots = spots {
                completion(spots)
            }
        }
    }
    
    public func deriveZipcodeFrom(location: CLLocation, completion: @escaping (String?, Error?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard error == nil, let placemarks = placemarks, let firstPlacemark = placemarks.first, let zipCode = firstPlacemark.postalCode else {
                completion(nil, error)
                return
            }
            
            completion(zipCode, nil)
        }
    }
    
}

