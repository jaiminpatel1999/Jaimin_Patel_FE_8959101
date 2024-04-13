//
//  WeatherViewController.swift
//  Jaimin_Patel_FE_8959101
//
//  Created by user237118 on 4/10/24.
//




import Foundation
import UIKit
import CoreLocation


// Codable class to parse and store weather response data
class WeatherResponse: Codable {
    var name: String
    var weather: [WeatherDetails]
    var main: MainDetails
    var wind: WindDetails
    
    init(name: String, weather: [WeatherDetails], main: MainDetails, wind: WindDetails) {
        self.name = name
        self.weather = weather
        self.main = main
        self.wind = wind
    }
}

// Codable class for details about the weather conditions
class WeatherDetails: Codable {
    var description: String
    var icon: String
    
    init(description: String, icon: String) {
        self.description = description
        self.icon = icon
    }
}

// Codable class for details about the weather conditions
class MainDetails: Codable {
    var temp: Double
    var humidity: Double
    
    init(temp: Double, humidity: Double) {
        self.temp = temp
        self.humidity = humidity
    }
}

// Codable class for wind details
class WindDetails: Codable {
    var speed: Double
    
    init(speed: Double) {
        self.speed = speed
    }
}

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    // Outlets for UI elements
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherDesc: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherHumidityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    
    
    
    
    // Location manager for handling location services
    let locationManager = CLLocationManager()
    var selectedCity: String?
    
    // API key for OpenWeatherMap API
    let apiKey = "7f90db7b759ff59bf1ab7f88b4d6d095"
    
    
    // Set up the view and request location access
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegate for the location manager
        locationManager.delegate = self
        // Request location authorization from the user when the app is in use
        locationManager.requestWhenInUseAuthorization()
        // Start updating location
        startUpdatingLocation()
    }
    
    
    // Action to change city manually via an alert dialog
    @IBAction func changeCity(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Change City", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter City"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let goAction = UIAlertAction(title: "Go", style: .default) { [weak self] _ in
            if let city = alertController.textFields?.first?.text {
                // Update the UI with the weather information for the selected city
                self?.updateWeather(for: city)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(goAction)
        
        present(alertController, animated: true, completion: nil)
    }

    // Fetch and update weather information for the specified city
    func updateWeather(for city: String) {
        // Perform weather data fetching or update based on the chosen city
        // Update the UI with the weather information
        selectedCity = city
        fetchWeatherData(for: city)
    }
    
    
    // Handle location authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    
    // Fetch new weather data when location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            fetchWeatherData(for: selectedCity ?? "")
        }
    }

    
    // Log any location manager errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }

    
    // Check and handle the current location authorization
    func checkLocationAuthorization() {
        let authorizationStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdatingLocation()
        } else if authorizationStatus == .denied {
            print("Location access denied.")
        } else if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if authorizationStatus == .restricted {
            print("Location access restricted.")
        }
    }

    
    // Start receiving location updates
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    // Stop receiving location updates
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // Fetch weather data from the API for a given city
    func fetchWeatherData(for city: String) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            print("Invalid API URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error fetching weather data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let weatherData = try decoder.decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.updateUI(with: weatherData)
                }
            } catch {
                print("Error parsing JSON data: \(error.localizedDescription)")
            }
        }.resume()
    }

    
    // Update the user interface with weather data
    func updateUI(with weatherResponse: WeatherResponse) {
        locationLabel.text = weatherResponse.name
        if let weather = weatherResponse.weather.first {
            weatherDesc.text = weather.description
            let iconCode = weather.icon
            let iconURLString = "https://openweathermap.org/img/w/\(iconCode).png"
            if let iconURL = URL(string: iconURLString), let iconData = try? Data(contentsOf: iconURL) {
                weatherImage.image = UIImage(data: iconData)
            }
        }
        tempLabel.text = "\(Int(weatherResponse.main.temp)) °C"
        weatherHumidityLabel.text = "Humidity: \(weatherResponse.main.humidity) %"
        windLabel.text = "Wind: \(weatherResponse.wind.speed) km/h"
    }
}

