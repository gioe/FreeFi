//
//  ServicesManager.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/2/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import Foundation
import GooglePlaces

public class ServicesManager: NSObject {
    
    let googlePlacesKey = "AIzaSyCNfGxCg5e3_31Zls8M9t6QVTs-Fq2AajU"
    public static let shared = ServicesManager()
    
    override private init() {
        super.init()
    }
    
    public func initializeServices() {
        GMSPlacesClient.provideAPIKey(googlePlacesKey)
    }
    
}

