//
//  Network.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/1/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import Foundation

public struct Network: Codable {
    var name: String
    var password: String
    
    enum NetworkKeys: String, CodingKey { // declaring our keys
        case name = "name"
        case password = "password"
    }
    
    init(name: String, password: String) {
        self.name = name
        self.password = password
    }
    
    init?(dictionary: JSONDictionary) {
        guard let name = dictionary["name"] as? String,
            let password = dictionary["password"] as? String
            else { return nil }
        self.name = name
        self.password = password
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NetworkKeys.self)
        let name: String = try container.decode(String.self, forKey: .name)
        let password: String = try container.decode(String.self, forKey: .password)
        self.init(name: name, password: password)
    }
}

