//
//  WeatherGetter.swift
//  DroneFlight
//
//  Created by Benjamin Durao on 10/13/16.
//  Copyright © 2016 CCSU. All rights reserved.
//

import Foundation

protocol WeatherGetterDelegate {
    func didGetWeather(weather: Weather)
    func didNotGetWeather(error: Error)
}

class WeatherGetter {
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "07290c2210a107633f084b34fc3d8169"
    
    private let delegate: WeatherGetterDelegate
    
    init(delegate: WeatherGetterDelegate) {
        self.delegate = delegate
    }
    
    func getWeatherByCity(city: String) {
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        getWeather(weatherRequestURL: weatherRequestURL)
    }
    
    func getWeatherByCoordinates(latitude: Double, longitude: Double) {
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(latitude)&lon=\(longitude)")!
        getWeather(weatherRequestURL: weatherRequestURL)
    }
    
    func getWeather(weatherRequestURL: URL) {
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: weatherRequestURL) {
            (data: Data?, reponse: URLResponse?, error: Error?) in
            if let networkError = error {
                self.delegate.didNotGetWeather(error: networkError)
            }
            else {
                do {
                    let weatherData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: AnyObject]

                    let weather = Weather(weatherData: weatherData!)
                    
                    self.delegate.didGetWeather(weather: weather)
                }
                catch let jsonError {
                    self.delegate.didNotGetWeather(error: jsonError)
                }
            }
        }
        dataTask.resume()
    }
}
