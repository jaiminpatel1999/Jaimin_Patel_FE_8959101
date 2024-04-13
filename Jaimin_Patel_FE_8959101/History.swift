//
//  History.swift
//  Jaimin_Patel_FE_8959101
//
//  Created by user237118 on 4/12/24.
//

import Foundation
import UIKit
import CoreLocation




class History: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
   
    
    @IBOutlet weak var table: UITableView!
    struct Cities {
        let cityName: String
        let latitude: String
        let longitude: String
        let imageName: String
    }
    
    var data: [Cities] = [
        Cities(cityName: "Toronto", latitude: "43.7001", longitude: "-79.4163", imageName: "toronto"),
        Cities(cityName: "Calgary", latitude: "51.0501", longitude: "-114.0853", imageName: "calgary"),
        Cities(cityName: "Winnipeg", latitude: "53.5501", longitude: "-113.4687", imageName: "winnipeg"),
        Cities(cityName: "Ottawa", latitude: "45.4112", longitude: "-75.6981", imageName: "ottawa"),
        Cities(cityName: "Montreal", latitude: "45.5088", longitude: "-73.5878", imageName: "montreal"),
    ]
    
    @IBAction func addCityButton(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Add City", message: "Enter the name of the city you like to explore", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "city Name"
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        }
        
        let addButton = UIAlertAction(title: "Add", style: .default) { (action) in
            if let cityName = alertController.textFields?.first?.text {
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(cityName) { (placemarks, error) in
                    if let error = error {
                        print("Error while geocoding: \(error)")
                        return
                    }
                    
                    if let placemarks = placemarks, let placemark = placemarks.first, let location = placemark.location {
                        let latitude = String(location.coordinate.latitude)
                        let longitude = String(location.coordinate.longitude)
                        
                        let randomImageName = self.data.randomElement()?.imageName ?? "defaultImage"
                        
                        let newCity = Cities(cityName: cityName, latitude: latitude, longitude: longitude, imageName: randomImageName)
                        
                        self.data.insert(newCity, at: 0)
                        
                        DispatchQueue.main.async {
                            self.table.reloadData()
                        }
                    }
                }
            }
        }
        
        addButton.isEnabled = false
        alertController.addAction(addButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func alertTextFieldDidChange(_ textField: UITextField) {
        // Enable the add button if the text field is not empty
        if let alertController = self.presentedViewController as? UIAlertController {
            let textField = alertController.textFields?.first
            let addButton = alertController.actions.last
            addButton?.isEnabled = !(textField?.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
                
        // Update the message if the text field is empty
            if textField?.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
                alertController.message = "City name must be filled."
            } else {
                alertController.message = "Enter the name of the city you want to add."
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let city = data[indexPath.row]
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        cell.delegate = self
        
        cell.cityNameLabel.text = city.cityName
        cell.latitudeLabel.text = city.latitude
        cell.longitudeLabel.text = city.longitude
        cell.cityImageView.image = UIImage(named: city.imageName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the city from the data array
            data.remove(at: indexPath.row)
            
            // Delete the corresponding row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension History: CustomTableViewCellDelegate {
    func didTapMapButton(cityName: String) {
        let mapViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewControllerID") as! Map
        mapViewController.cityName = cityName
        navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    func didTapWeatherButton(cityName: String) {
        let weatherViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeatherViewControllerID") as! Weather
        weatherViewController.cityName = cityName
        navigationController?.pushViewController(WeatherViewController, animated: true)
    }
}
