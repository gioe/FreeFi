//
//  SpotsService.swift
//  FreeFi
//
//  Created by Matt Gioe on 11/12/17.
//  Copyright © 2017 Matt Gioe. All rights reserved.
//

import Foundation
public class SpotsService {
    
    internal enum ServerError: String, InternalError, Error {
        case duplicateSpot = "This spot already exists."
        
        var errorMessage: String {
            switch self {
            default: return self.rawValue
            }
        }
    }
    
    public static let sharedInstance = SpotsService()
    
    func postSpotsUrl() -> URL? {
        if let url = URL(string: "https://freefiapp.herokuapp.com/place/new") {
            return url
        }
        return nil
    }
    
    func updateSpotUrl() -> URL? {
        if let url = URL(string: "https://freefiapp.herokuapp.com/place/update") {
            return url
        }
        return nil
    }
    
    func getSpotsUrl(zipCode: String) -> URL? {
        if let url = URL(string: "https://freefiapp.herokuapp.com/nearbyPlaces/\(zipCode)") {
            return url
        }
        return nil
    }
    
    public func postSpot(_ spot: Spot, _ completion: @escaping (_ response: Bool, _ error: InternalError?) -> Void) {
        
        var request = URLRequest(url: postSpotsUrl()!)
        request.httpMethod = "POST"
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(spot)
        
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let responseData = data, let parsedResponse = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                completion(false, nil)
                return
            }
            
            if let parsedResponse = parsedResponse, let message = parsedResponse["message"] as? String, let error = ServerError(rawValue: message) {
                completion(false, error)
                return
            }
            completion(true, nil)
            
            }.resume()
    }
    
    public func getNearbySpots(_ zipCode: String, completion: @escaping (_ spot: [Spot]?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) {
        
        var request = URLRequest(url: getSpotsUrl(zipCode: zipCode)!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in

            if error != nil {
                completion(nil, nil, error)
            }
            
            guard let data = data else { return }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                if let jsonArray = jsonData["data"] as? [JSONDictionary] {
                    let spotsData = jsonArray.flatMap{ Spot(dictionary: $0) }
                    completion(spotsData, nil, nil)
                }
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    }
    
    public func updateSpot(_ spot: Spot, _ completion: @escaping (_ response: Bool, _ error: InternalError?) -> Void) {
        
        var request = URLRequest(url: updateSpotUrl()!)
        request.httpMethod = "PUT"
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(spot)
        
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let responseData = data, let parsedResponse = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                completion(false, nil)
                return
            }
            
            if let parsedResponse = parsedResponse, let message = parsedResponse["message"] as? String, let error = ServerError(rawValue: message) {
                completion(false, error)
                return
            }
            completion(true, nil)
            
            }.resume()
    }
    
}
