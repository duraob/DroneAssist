//
//  AirportGetter.swift
//  DroneFlight
//
//  Created by Benjamin Durao on 10/21/16.
//  Copyright © 2016 CCSU. All rights reserved.
//

import Foundation

protocol AirportGetterDelegate {
    func didGetAirport(airport: Airport)
    func didNotGetAirport(error: Error)
}

class AirportGetter {
    private let googleMapBaseURL = "https://maps.googleapis.com/maps/api/place"
    private let googleMapAPIKey = "AIzaSyCt0uY4ey1J0xpJciO4BOFTEa9OMI6xiGs"
    private let delegate: AirportGetterDelegate
    
    init(delegate: AirportGetterDelegate) {
        self.delegate = delegate
    }
    
    
    func getAirportByCoordinates(latitude: Double, longitude: Double) {
        let airportRequestURL = URL(string: "\(googleMapBaseURL)/nearbysearch/json?location=\(latitude),\(longitude)&radius=8046&type=airport&key=\(googleMapAPIKey)")!
        print("GOOGurl: \(airportRequestURL)")
        getAirport(airportRequestURL: airportRequestURL)
    }
    
    func getAirport(airportRequestURL: URL) {
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: airportRequestURL) {
            (data: Data?, reponse: URLResponse?, error: Error?) in
            if let networkError = error {
                self.delegate.didNotGetAirport(error: networkError)
            }
            else {
                do {
                    let jsonObject: AnyObject = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as AnyObject
                    
                    let jsonDictionary = jsonObject as? [String: AnyObject]
                    let airportsArray = jsonDictionary?["results"] as? [[String: AnyObject]]
                    if (!(airportsArray?.isEmpty)!)
                    {
                        let airportObj = airportsArray?[0]
                        let airport = Airport(airportObj!)
                        self.delegate.didGetAirport(airport: airport)
                    }
                }
                catch let jsonError {
                    self.delegate.didNotGetAirport(error: jsonError)
                }
            }
        }
        dataTask.resume()
    }
}
