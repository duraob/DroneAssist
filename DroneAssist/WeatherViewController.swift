//
//  WeatherViewController.swift
//  DroneFlight
//
//  Created by Benjamin Durao on 10/13/16.
//  Copyright © 2016 CCSU. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, WeatherGetterDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    // MARK: Properties
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    
    var weather: WeatherGetter!
    var locationManager: CLLocationManager!
    
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weather = WeatherGetter(delegate: self)
        
        cityTextField.delegate = self
        
        cityLabel.text = "simple weather"
        weatherLabel.text = ""
        temperatureLabel.text = ""
        cloudCoverLabel.text = ""
        windLabel.text = ""
        rainLabel.text = ""
        humidityLabel.text = ""
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 1000
            locationManager.requestLocation()
        }
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "DroneAmmend.png")!)
    }
    
    // MARK: WeatherGetterDelegate
    func didGetWeather(weather: Weather) {
        DispatchQueue.main.async {
            print("got weather")
            self.cityLabel.text = weather.city
            self.weatherLabel.text = weather.weatherDescription
            self.temperatureLabel.text = "\(Int(round(weather.tempFahrenheit)))"
            self.cloudCoverLabel.text = "\(weather.cloudCover)%"
            self.windLabel.text = String(format: "%.2f mph", weather.windSpeed as Double)
            
            if let rain = weather.rainfallInLast3Hours {
                self.rainLabel.text = "\(rain) mm"
            }
            else {
                self.rainLabel.text = "None"
            }
            
            self.humidityLabel.text = "\(weather.humidity)%"
        }
    }
    
    func didNotGetWeather(error: Error) {
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
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }

    
    // MARK: CLLocationManagerDelegate
    // Setup location manager and print error otherwise
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: " + error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        weather.getWeatherByCoordinates(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
    }
    
    // Other City Weather Search
    @IBAction func searchWeatherByCityName(_ sender: Any) {
        guard let text = cityTextField.text, !text.isEmpty else {
            return
        }
            weather?.getWeatherByCity(city: (cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)

    }
    
    @IBAction func getCurrentLocationWeather(_ sender: Any) {
        locationManager.requestLocation()
    }
    
    
}
