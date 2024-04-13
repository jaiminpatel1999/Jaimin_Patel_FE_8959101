//
//  ViewController.swift
//  Jaimin_Patel_FE_8959101
//
//  Created by user237118 on 4/8/24.
//



import UIKit
import CoreLocation
import MapKit

// MARK: - Welcome
// This structure represents the main data model used for the decoded JSON from the weather API.
struct Welcome: Codable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone, id: Int
    let name: String
    let cod: Int
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}

// MARK: - Main
struct Main: Codable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Sys
struct Sys: Codable {
    let type, id: Int
    let country: String
    let sunrise, sunset: Int
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main, description, icon: String
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
}

// ViewController manages the user interface for displaying weather information.
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // Weather data properties
    var cityName = ""
    var weatherDisc = ""
    var temprature = 0.0;
    var humidity = 0;
    var wind = 0.0;
    var lat="";
    var lon="";
    var image="";
    
    
    // UI outlets
    @IBOutlet weak var labelCityName: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var labelTemperature: UILabel!
    @IBOutlet weak var labelHumidity: UILabel!
    @IBOutlet weak var labelWindSpeed: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    // Location and session managers
    let locationManager = CLLocationManager()
    let urlSession = URLSession(configuration:.default)
    
    // Updates locations and triggers a new fetch for weather data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        lat = "\(locValue.latitude)"
        lon = "\(locValue.longitude)"
        fetchWeather();
        guard let location = locations.last else { return }
        
        // Adjust map to show new location
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
   
    let manager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        super.viewDidLoad()
        
        // Set up location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Set up map view
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    
    // Fetches weather data from OpenWeatherMap API
    func fetchWeather(){
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=7f90db7b759ff59bf1ab7f88b4d6d095&units=metric")
        
        if let url = url {
            let dataTask = urlSession.dataTask(with: url) { [self] (data, response, error) in
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let readableData = try jsonDecoder.decode(Welcome.self, from: data)
                        self.cityName = readableData.name
                        self.weatherDisc = readableData.weather[0].description
                        self.temprature = readableData.main.temp
                        self.humidity = readableData.main.humidity
                        self.wind = readableData.wind.speed
                        self.image = readableData.weather[0].icon
                        
                        print(readableData);
                        
                    }
                    catch {
                        print ("Can't Decode")
                    }
                    DispatchQueue.main.async {
                        labelCityName.text = "\(cityName)"
                        labelDescription.text = "\(weatherDisc.capitalized)"
                        labelTemperature.text = "\(temprature)º C"
                        labelHumidity.text = "\(humidity)%"
                        labelWindSpeed.text = "\(wind)km/h"
                        //weatherIcon.image = UIImage(
                        let url = URL(string: "https://openweathermap.org/img/wn/\(image).png")!
                        
                        // Fetch Image Data
                        if let data = try? Data(contentsOf: url) {
                            // Create Image and Update Image View
                            weatherIcon.image = UIImage(data: data)
                        }
                        
                    }
                }
            }
            dataTask.resume()
        }
    }
}


extension ViewController: MKMapViewDelegate {
    // Map view delegate methods can be implemented here if needed
}
