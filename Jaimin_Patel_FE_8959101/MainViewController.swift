//
//  MainViewController.swift
//  Jaimin_Patel_FE_8959101
//
//  Created by user237118 on 4/11/24.
//

import Foundation
import UIKit
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Request location authorization
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Setup map view
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update map view to show current location
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        // Fetch weather data for current location
        fetchWeatherData(for: location.coordinate)
        
        // Stop updating location to save battery
        locationManager.stopUpdatingLocation()
    }
    
    func fetchWeatherData(for coordinate: CLLocationCoordinate2D) {
        // Replace "YOUR_API_KEY" with your actual API key
        let apiKey = "YOUR_API_KEY"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        if let weatherData = json as? [String: Any] {
                            if let weather = weatherData["weather"] as? [[String: Any]],
                               let main = weatherData["main"] as? [String: Any],
                               let wind = weatherData["wind"] as? [String: Any] {
                                if let weatherDescription = weather.first?["description"] as? String,
                                   let temp = main["temp"] as? Double,
                                   let humidity = main["humidity"] as? Int,
                                   let windSpeedMetersPerSecond = wind["speed"] as? Double {
                                    // Convert wind speed from m/s to km/h
                                    let windSpeedKmPerHour = windSpeedMetersPerSecond * 3.6
                                    
                                    DispatchQueue.main.async {
                                        self.weatherDescriptionLabel.text = "Weather: \(weatherDescription)"
                                        self.temperatureLabel.text = "Temperature: \(temp)°C"
                                        self.humidityLabel.text = "Humidity: \(humidity)%"
                                        self.windSpeedLabel.text = "Wind Speed: \(windSpeedKmPerHour) km/h"
                                    }
                                }
                            }
                        }
                    } catch {
                        print("Error parsing weather data: \(error.localizedDescription)")
                    }
                }
            }.resume()
        }
    }
}

extension ViewController: MKMapViewDelegate {
    // You can implement mapView delegate methods here if needed
}
