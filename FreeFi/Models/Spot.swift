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
        case id
        case name
        case address
        case city
        case state
        case zipCode
        case latitude
        case longitude
        case networks
    }
    
    var id: Int
    var name: String
    var address: String
    var city: String
    var state: String
    var zipCode: Int
    var latitude: Double
    var longitude: Double
    var networks: [Network]?
    
    init(id: Int = 0, name: String, address: String, city: String, state: String, zipCode: Int, latitude: Double, longitude: Double, networks: [Network]? = nil ) {
        self.id = id
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.latitude = latitude
        self.longitude = longitude
        self.networks = networks
    }
    
    init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? Int,
            let name = dictionary["name"] as? String,
            let address = dictionary["address"] as? String,
            let city = dictionary["city"] as? String,
            let state = dictionary["state"] as? String,
            let zipCode = dictionary["zipCode"] as? Int,
            let latitude = dictionary["latitude"] as? Double,
            let longitude = dictionary["longitude"] as? Double,
            let networkArray = dictionary["networks"] as? [JSONDictionary]
            else { return nil }
        
        self.id = id
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.latitude = latitude
        self.longitude = longitude
        self.networks = networkArray.flatMap{ Network(dictionary: $0) }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SpotKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let address = try container.decode(String.self, forKey: .address)
        let city = try container.decode(String.self, forKey: .city)
        let state = try container.decode(String.self, forKey: .state)
        let zipCode = try container.decode(Int.self, forKey: .zipCode)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        let networks: [Network] = try container.decode([Network].self, forKey: .networks)
        self.init(id: id, name: name, address: address, city: city, state: state, zipCode: zipCode, latitude: latitude, longitude: longitude, networks: networks)
    }
}

