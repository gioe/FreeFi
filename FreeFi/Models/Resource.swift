//
//  Resource.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/9/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import Foundation

struct Resource<A> {
    let request: URLRequest
    let parse: (Data) -> A?
}

extension Resource {
    init(url: URLRequest, parseJSON: @escaping (Any) -> A?) {
        self.request = url
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json.flatMap(parseJSON)
        }
    }
}

