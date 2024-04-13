//
//  Map.swift
//  Jaimin_Patel_FE_8959101
//
//  Created by user237118 on 4/10/24.
//

import UIKit
import MapKit

class Map: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // IBOutlets
    @IBOutlet weak var mapSlider: UISlider!
    @IBOutlet weak var myMapView: MKMapView!
    
    
    // Location manager for getting user's location
    var locationManager: CLLocationManager?
   
    // Destination location for the route
    var destinationLocation: CLLocation?
    
    // Selected transportation mode for the route
    var selectedTransportationMode: MKDirectionsTransportType = .automobile
    
    // Alert controller for getting start and destination locations
    var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize location manager and set delegate
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        
        // Start updating location if location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.startUpdatingLocation()
        }
        
        // Set map view delegate
        if let myMapView = myMapView {
            myMapView.delegate = self
        }
        
        // Set initial map region to user's location
        if let userLocation = locationManager?.location?.coordinate {
            let initialRegion = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            myMapView.setRegion(initialRegion, animated: true)
        }
    }
    
    // Action for car mode button
    @IBAction func carMode(_ sender: UIButton) {
        selectedTransportationMode = .automobile
        updateMapForSelectedMode()
    }
    
    // Action for walking mode button
    @IBAction func walkingMode(_ sender: UIButton) {
        selectedTransportationMode = .walking
        updateMapForSelectedMode()
    }
    
    
    
    // Update map for selected transportation mode
    func updateMapForSelectedMode() {
        if let startLocation = alertController?.textFields?[0].text,
           let destination = alertController?.textFields?[1].text{
            calculateRoute(start: startLocation, destination: destination)
        }
    }
    
    
    // Action for slider change
    @IBAction func sliderChange(_ sender: UISlider) {
        let currentRegion = myMapView.region
        let newRegion = MKCoordinateRegion(
            center: currentRegion.center,
            span: MKCoordinateSpan(
                latitudeDelta: CLLocationDegrees(sender.value),
                longitudeDelta: CLLocationDegrees(sender.value)
            )
        )
        myMapView.setRegion(newRegion, animated: true)
    }
    
    
    // Action for adding destination location button
    @IBAction func addDestinationLocation(_ sender: UIBarButtonItem) {
        
        // Create alert controller with text fields for start and destination locations
        alertController = UIAlertController(title: "Enter Locations", message: nil, preferredStyle: .alert)
        
        alertController?.addTextField { textField in
            textField.placeholder = "Enter Start Location"
        }
        alertController?.addTextField { textField in
            textField.placeholder = "Enter Destination"
        }
        
        // Add cancel and go actions to alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let goAction = UIAlertAction(title: "Go", style: .default) { [weak self] _ in
            if let startLocation = self?.alertController?.textFields?[0].text,
               let destination = self?.alertController?.textFields?[1].text {
                self?.calculateRoute(start: startLocation, destination: destination)
            }
        }
        
        alertController?.addAction(cancelAction)
        alertController?.addAction(goAction)
        
        // Present alert controller
        present(alertController!, animated: true, completion: nil)
    }
    
    // Calculate route between start and destination locations
    func calculateRoute(start startLocation: String, destination destinationLocation: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(startLocation) { [weak self] (startPlacemarks, startError) in
            guard let startPlacemark = startPlacemarks?.first, let startCoordinate = startPlacemark.location?.coordinate else {
                print("Error geocoding start location: \(startError?.localizedDescription ?? "")")
                return
            }
            
            geocoder.geocodeAddressString(destinationLocation) { [weak self] (destinationPlacemarks, destinationError) in
                guard let destinationPlacemark = destinationPlacemarks?.first, let destinationCoordinate = destinationPlacemark.location?.coordinate else {
                    print("Error geocoding destination location: \(destinationError?.localizedDescription ?? "")")
                    return
                }
                
                self?.addPin(at: startCoordinate, title: "Start", subtitle: startLocation)
                self?.addPin(at: destinationCoordinate, title: "Destination", subtitle: destinationLocation)
                self?.showRoute(start: startCoordinate, destination: destinationCoordinate)
            }
        }
    }
    
    
    // Show route on the map view
    func showRoute(start startCoordinate: CLLocationCoordinate2D, destination destinationCoordinate: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = selectedTransportationMode
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [weak self] response, error in
            guard let route = response?.routes.first else {
                if let error = error {
                    print("Error calculating route: \(error)")
                }
                return
            }
            
            self?.myMapView.removeOverlays(self?.myMapView.overlays ?? [])
            self?.myMapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let routeRect = route.polyline.boundingMapRect
            self?.myMapView.setRegion(MKCoordinateRegion(routeRect), animated: true)
        }
    }
    
    // Add pin at specified coordinate
    func addPin(at coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        myMapView.addAnnotation(annotation)
    }
    
    
    // Render polyline for the route
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer()
    }
    
}

