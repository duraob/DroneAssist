//
//  Airport.swift
//  DroneFlight
//
//  Created by Benjamin Durao on 10/21/16.
//  Copyright © 2016 CCSU. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import Contacts
import CoreLocation

struct GeoKey {
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let radius = "radius"
    static let identifier = "identifier"
    static let title = "title"
    static let vicinity = "vicinity"
}

enum EventType: String {
    case onEntry = "On Entry"
    case onExit = "On Exit"
}

class Airport: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let vicinity: String
    let longitude: CLLocationDegrees
    let latitude: CLLocationDegrees
    var radius: CLLocationDistance
    var indentifer: String
    
    
    init(_ json: [String: AnyObject]) {
        let geometryDict = json["geometry"] as! [String: AnyObject]
        let coordDict = geometryDict["location"] as! [String: AnyObject]
        latitude = coordDict["lat"] as! Double
        longitude = coordDict["lng"]as! Double
        //title = "No Fly Zone"
        vicinity = json["vicinity"] as! String
        title = json["name"] as? String
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        indentifer = json["id"] as! String
        radius = 8046.72 // meters or 5 miles radius as specified by FAA
        
        super.init()
    }
    
    var subtitle: String? {
        return vicinity
    }
    // MARK: - MapKit related methods
    
    // annotation callout opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
}

