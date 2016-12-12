//
//  ViewController.swift
//  DroneFlight
//
//  Created by Benjamin Durao on 10/5/16.
//  Copyright © 2016 CCSU. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class MapViewController: UIViewController, CLLocationManagerDelegate, AirportGetterDelegate {
    // MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    var lat: CLLocationCoordinate2D!
    var lng: CLLocationCoordinate2D!
    
    //Timer
    var timer = Timer()
    var seconds = 0.0
    
    // Map and Locattion Services
    var locationManager: CLLocationManager!
    var airport: AirportGetter!
    var airports: [Airport] = [] {
        didSet
        {
            mapView.addAnnotations(airports)
            for index in 0..<airports.count
            {
              //  if airports[index].identifer !=
                addRadiusOverlay(forAirport: airports[index])
                startMonitoring(airport: airports[index])
            }
        }
    }
    
    // Searching
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        airport = AirportGetter(delegate: self)
        
        // Setup LocationManager Delegate and mapView Delegate and AirportGetterDelegate
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 500
            locationManager.startUpdatingLocation()
            
            // Map View Delegate
            mapView.delegate = self
            mapView.showsUserLocation = true
            
            
            guard let coordinate = mapView?.userLocation.coordinate else { return }
            let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
            mapView.setRegion(region, animated: true)
            
            // Searching
            // Setup Search Controller
            let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
            resultSearchController = UISearchController(searchResultsController: locationSearchTable)
            resultSearchController?.searchResultsUpdater = locationSearchTable
            
            // Setup up Search Bar
            let searchBar = resultSearchController!.searchBar
            searchBar.sizeToFit()
            searchBar.placeholder = "Search for destination..."
            navigationItem.titleView = resultSearchController?.searchBar
            
            // UISearchController Appearance
            resultSearchController?.hidesNavigationBarDuringPresentation = false
            resultSearchController?.dimsBackgroundDuringPresentation = true
            definesPresentationContext = true
            
            // Pass map view from main controller to LocationSearchTable
            locationSearchTable.mapView = mapView
            locationSearchTable.handleMapSearchDelegate = self

        }
        
    }

    // Get the nearby airports from User Location
    func loadData()
    {
        locationManager.requestLocation()
        let latPoint = locationManager.location?.coordinate.latitude
        let lngPoint = locationManager.location?.coordinate.longitude
        airport.getAirportByCoordinates(latitude: latPoint!, longitude: lngPoint!)
    }

    
    // GeoFence methods
    func region(withAirport airport: Airport) -> CLCircularRegion {
        let region = CLCircularRegion(center: airport.coordinate, radius: airport.radius, identifier: airport.indentifer)
        region.notifyOnEntry = true
        return region
    }
    
    func startMonitoring(airport: Airport) {
        locationManager.requestAlwaysAuthorization()
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showSimpleAlert(title:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            showSimpleAlert(title:"Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
        }
        let region = self.region(withAirport: airport)
        locationManager.startMonitoring(for: region)
    }
    
    func stopMonitoring(airport: Airport)
    {
        for region in locationManager.monitoredRegions
        {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == airport.indentifer
                else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    // Geo Fence Alert
    func handleEvent(forRegion region: CLRegion!) {
        print("Geofence triggered!")
        showSimpleAlert(title: "Turn Around", message: "Warning: You have entered a flagged no fly zone.")
    }

    // Location Manager Geo Fence Event Handler
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    // Create Overlay
    func addRadiusOverlay(forAirport airport: Airport) {
        mapView?.add(MKCircle(center: airport.coordinate, radius: airport.radius))
    }
    
    func addRadiusOverlay2(forPin pin: Pin) {
        mapView?.add(MKCircle(center: pin.coordinate, radius: pin.radius))

    }
    
    // MARK: Timer Methods
    @IBAction func timeToggle(_ sender: AnyObject) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.updateCounter), userInfo: nil, repeats: true)
        playButton.isEnabled = false
        playButton.tintColor = UIColor.black
        refreshButton.isEnabled = false
        refreshButton.tintColor = UIColor.black
        saveButton.isEnabled = false
        saveButton.tintColor = UIColor.black
        
        
    }

    @IBAction func resetToggle(_ sender: AnyObject) {
        timer.invalidate()
        seconds = 0.0
        timerLabel.text = "\(timeString(time: seconds))"
        playButton.isEnabled = true
        playButton.tintColor = UIColor.blue
        saveButton.isEnabled = true
        saveButton.tintColor = UIColor.blue
    }

    @IBAction func stopToggle(_ sender: AnyObject) {
        timer.invalidate()
        playButton.isEnabled = true
        playButton.tintColor = UIColor.blue
        refreshButton.isEnabled = true
        refreshButton.tintColor = UIColor.blue
        saveButton.isEnabled = true
        saveButton.tintColor = UIColor.blue
        
    }
    
    func updateCounter() {
        seconds += 1.0
        timerLabel.text = "\(timeString(time: seconds))"
    }
    
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    //MARK: Save Button Methods
    @IBAction func saveBtn(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Save Flight", message: "Are you sure you want this saved?", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func returnToCurrentLocation(_ sender: Any) {
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegionMake((locationManager.location?.coordinate)!, span)
        self.mapView.setRegion(region, animated: true)
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        showSimpleAlert(title: "Location Manager Error", message: "Monitoring failed for region: \(region?.identifier)")
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showSimpleAlert(title: "Location Manager Error", message: "Monitoring failed with error: \(error)")
        print("Location Manager failed with the following error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        let lat = newLocation.coordinate.latitude
        let lng = newLocation.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.75
        let lonDelta: CLLocationDegrees = 0.75
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        self.mapView.setRegion(region, animated: true)
        loadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        manager.requestAlwaysAuthorization()
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
    
    // MARK: AirportGetterDelegate
    func didGetAirport(airport: Airport) {
        DispatchQueue.main.async {
            self.airports.append(airport)
            print("got airport \(airport.title)")
        }
    }
    
    func didNotGetAirport(error: Error) {
        DispatchQueue.main.async {
            self.showSimpleAlert(title: "Can't get the weather", message: "The weather service is not responding.")
        }
        
        print("didNotGetWeather error: \(error)")
    }
    
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

}
// EXTENSIONS
// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Airport {
            let identifier = annotation.indentifer
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
                view.pinTintColor = UIColor.purple
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.pinTintColor = UIColor.purple
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Airport
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    
    // segue to send timer to flight data
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if (segue.identifier == "AddItem") {
                let nvc = segue.destination as! UINavigationController
                let fvc = nvc.topViewController as! FlightViewController
                fvc.time = (timerLabel?.text)!
                let lat = self.locationManager.location?.coordinate.latitude
                let lng = self.locationManager.location?.coordinate.longitude
                if let lat = lat {
                    fvc.lat = String(format: "%.2f", lat as Double)
                }
                if let lng = lng {
                    fvc.lng = String(format: "%.2f", lng as Double)

                }
        }
        
    }
}

// Searching the Map Delegate

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.title
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.75, 0.75)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        self.mapView.setRegion(region, animated: true)
        
        airport.getAirportByCoordinates(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
    }
}
