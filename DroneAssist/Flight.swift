//
//  Flight.swift
//  DroneFlight
//
//  Created by Benjamin Durao on 10/25/16.
//  Copyright © 2016 CCSU. All rights reserved.
//

import UIKit
import MapKit

class Flight: NSObject, NSCoding {
    // MARK: Properties
    var name: String
    var photo: UIImage
    var notes: String
    var longitude: String
    var latitude: String
    var time: String
    var weather: String
    var wind: String
    
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("flights")
    
    
    // MARK: Types
    
    struct PropertyKey {
        static let nameKey = "name"
        static let photoKey = "photo"
        static let notesKey = "notes"
        static let longitudeKey = "longitude"
        static let latitudeKey = "latitude"
        static let timeKey = "time"
        static let weatherKey = "weather"
        static let windKey = "wind"
    }
    
    // MARK: Initialization
    init?(name: String, photo: UIImage?, notes: String?, time: String, longitude: String, latitude: String, wind:String, weather: String) {
        // Initialize stored properties
        self.name = name
        self.photo = photo!
        self.notes = notes!
        self.time = time
        self.longitude = longitude
        self.latitude = latitude
        self.weather = weather
        self.wind = wind
        
        if name.isEmpty || time.isEmpty || latitude.isEmpty || longitude.isEmpty
        {
            return nil
        }
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(photo, forKey: PropertyKey.photoKey)
        aCoder.encode(notes, forKey: PropertyKey.notesKey)
        aCoder.encode(time, forKey: PropertyKey.timeKey)
        aCoder.encode(longitude, forKey: PropertyKey.longitudeKey)
        aCoder.encode(latitude, forKey: PropertyKey.latitudeKey)
        aCoder.encode(weather, forKey: PropertyKey.weatherKey)
        aCoder.encode(wind, forKey: PropertyKey.windKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photoKey) as? UIImage
        let notes = aDecoder.decodeObject(forKey: PropertyKey.notesKey) as? String
        let time = aDecoder.decodeObject(forKey: PropertyKey.timeKey) as! String
        let longitude = aDecoder.decodeObject(forKey: PropertyKey.longitudeKey) as! String
        let latitude = aDecoder.decodeObject(forKey: PropertyKey.latitudeKey) as! String
        let wind = aDecoder.decodeObject(forKey: PropertyKey.windKey) as! String
        let weather = aDecoder.decodeObject(forKey: PropertyKey.weatherKey) as! String
        
        // Must call designated initalizer.
        self.init(name: name, photo: photo, notes: notes, time: time, longitude: longitude, latitude: latitude, wind: wind, weather: weather)
    }
}
