//
//  Pin.swift
//  DroneFlight
//
//  Created by Benjamin Durao on 10/22/16.
//  Copyright © 2016 CCSU. All rights reserved.
//

import Foundation
import MapKit

class Pin: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var indentifer: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        self.title = title
        self.coordinate = coordinate
        self.radius = radius
        self.indentifer = "Home"
        
    }
    
}
