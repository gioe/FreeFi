//
//  Network.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/1/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import Foundation

public struct Network: Codable {
    var id: Int
    var name: String
    var password: String
    
    enum NetworkKeys: String, CodingKey { // declaring our keys
        case id
        case name
        case password
    }
    
    init(id: Int = 0, name: String, password: String) {
        self.id = id
        self.name = name
        self.password = password
    }
    
    init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? Int,
            let name = dictionary["name"] as? String,
            let password = dictionary["password"] as? String
            else { return nil }
        self.id = id
        self.name = name
        self.password = password
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NetworkKeys.self)
        let id: Int = try container.decode(Int.self, forKey: .id)
        let name: String = try container.decode(String.self, forKey: .name)
        let password: String = try container.decode(String.self, forKey: .password)
        self.init(id: id, name: name, password: password)
    }
}

