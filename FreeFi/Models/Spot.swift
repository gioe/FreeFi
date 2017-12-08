//
//  Spot.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/1/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import Foundation
import CoreLocation

enum BackendError: Error {
    case urlError(reason: String)
    case objectSerialization(reason: String)
}

public typealias JSONDictionary = [String: AnyObject]

public protocol Locateable {
    
}
public struct Spot: Codable {
    
    enum SpotKeys: String, CodingKey { // declaring our keys
        case name = "name"
        case address = "address"
        case zipCode = "zipCode"
        case latitude = "latitude"
        case longitude = "longitude"
        case networks = "networks"
    }
    
    var name: String?
    var address: String?
    var zipCode: Int?
    var latitude: Double
    var longitude: Double
    var networks: [Network]?
    
    init(name: String, address: String, zipCode: Int, latitude: Double, longitude: Double, networks: [Network]? = nil ) {
        self.name = name
        self.address = address
        self.zipCode = zipCode
        self.latitude = latitude
        self.longitude = longitude
        self.networks = networks
    }
    
    init?(dictionary: JSONDictionary) {
        guard let name = dictionary["name"] as? String,
            let address = dictionary["address"] as? String,
            let zipCode = dictionary["zipCode"] as? Int,
            let latitude = dictionary["latitude"] as? Double,
            let longitude = dictionary["longitude"] as? Double,
            let networkArray = dictionary["networks"] as? [JSONDictionary]
            else { return nil }
        
        self.name = name
        self.address = address
        self.zipCode = zipCode
        self.latitude = latitude
        self.longitude = longitude
        self.networks = networkArray.flatMap{ Network(dictionary: $0) }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SpotKeys.self)
        let name: String = try container.decode(String.self, forKey: .name)
        let address: String = try container.decode(String.self, forKey: .address)
        let zipCode: Int = try container.decode(Int.self, forKey: .zipCode)
        let latitude: Double = try container.decode(Double.self, forKey: .latitude)
        let longitude: Double = try container.decode(Double.self, forKey: .longitude)
        let networks: [Network] = try container.decode([Network].self, forKey: .networks)
        self.init(name: name, address: address, zipCode: zipCode, latitude: latitude, longitude: longitude, networks: networks)
    }
}

