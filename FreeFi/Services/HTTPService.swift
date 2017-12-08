//
//  HTTPService.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/9/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import Foundation

final class HTTPService {
    func getAll<T>(resource: Resource<T>, completion: @escaping (Any) -> ()) {
        URLSession.shared.dataTask(with: resource.request) { (data, __, _) in
            completion(data.flatMap(resource.parse))
            }.resume()
    }
}

