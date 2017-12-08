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
    
}

