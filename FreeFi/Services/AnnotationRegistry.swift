//
//  AnnotationRegistry.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/8/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import Foundation
import MapKit

public class AnnotationRegistry {
    public static let shared = AnnotationRegistry()
    
    public var registryDict: [String: Spot] = [:]
    
}

