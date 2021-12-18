//
//  ViewController.swift
//  BinApp
//
//  Created by Jordan Porter on 09/04/2019.
//  Copyright © 2019 Jordan Porter. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var allRecyclingLocations: [MapPin]?
    var selectedRecyclingLocations: [MapPin]?
    var selectedRecyclingType = RecyclingType(rawValue: "glass")
    var selectedLocation: MapPin?
    
    let locationDataController = LocationDataController()
    let locationManager = CLLocationManager()
    let userLocationController = UserLocationController()
    let errorAlertController = ErrorAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        userLocationController.checkLocationSerivces { (success) in
            if success {
                self.centerMapOnUser()
            } else {
                self.errorAlertController.showErrorAlertView(in: self, with: "Location Not Found", and: "Could not retrive your current location. Please check your settings.")
            }
        }
        
        mapView.userTrackingMode = .none
        
        setupUserTrackingButton()
        registerForAnnotationViewClasses()
        getMapPins()
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            
            self.tabBarController?.tabBar.standardAppearance = appearance
            self.tabBarController?.tabBar.scrollEdgeAppearance = appearance
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToDifferentView), name: NSNotification.Name(rawValue: "DetailButtonPressed"), object: nil)
        
        mapView.layoutMargins = view.safeAreaInsets
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        for trackingButton in self.view.subviews {
            if trackingButton.isKind(of: MKUserTrackingButton.self){
                trackingButton.removeFromSuperview()
            }
        }
        
        setupUserTrackingButton()
    }
    
    func setupUserTrackingButton() {
        let button = MKUserTrackingButton(mapView: mapView)
        button.backgroundColor = UIColor.secondarySystemBackground
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                                     button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)])
    }
    
    func centerMapOnUser() {
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        
        guard let currentLocation: CLLocationCoordinate2D = locationManager.location?.coordinate else {
            errorAlertController.showErrorAlertView(in: self, with: "Location Not Found", and: "Could not retrive your current location. Please check your settings.")
            return
        }
        centerMap(on: currentLocation)
    }
    
    func centerMap(on location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func getMapPins() {
        if let locationData = locationDataController.getLocalLocationData() {
            self.createMapAnnotations(locations: locationData)
        } else  {
            locationDataController.fetchLocations { (locations) in
                guard let locations = locations else {
                    self.errorAlertController.showErrorAlertView(in: self, with: "Location Not Found", and: "Could not retrive your current location. Please check your settings.")
                    return
                }
                DispatchQueue.main.async {
                    self.createMapAnnotations(locations: locations)
                }
            }
        }
    }
    
    func createMapAnnotations(locations: [RecyclingLocation]) {
        var recyclingMapPins: [MapPin] = []

        for location in locations {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let recyclingPin = MapPin(coordinate: coordinate, title: location.name, subtitle: location.typeDescription, type: location.type, address: location.address, postcode: location.postcode)
            recyclingMapPins.append(recyclingPin)
        }
        self.allRecyclingLocations = recyclingMapPins
        addAnnotationsToMap()
    }
    
    func addAnnotationsToMap() {
        var recyclingMapPins: [MapPin] = []
        if let allRecyclingLocions = allRecyclingLocations {
            mapView.removeAnnotations(allRecyclingLocions)
            
            for pin in allRecyclingLocions {
                if pin.type == selectedRecyclingType.description {
                    pin.distance = distance(to: pin.coordinate)
                    recyclingMapPins.append(pin)
                }
            }
            let sortedMapPins = orderPinsByDistance(mapPins: recyclingMapPins)
            
            self.selectedRecyclingLocations = sortedMapPins
            mapView.addAnnotations(recyclingMapPins)
        }
    }
    
    func orderPinsByDistance(mapPins: [MapPin]) -> [MapPin]? {
        
        let sortedPins = mapPins.sorted { (pin1, pin2) -> Bool in
            guard let distance1 = pin1.distance, let distance2 = pin2.distance else { return false }
            return distance1 < distance2
        }
        
        return sortedPins
    }
    
    func distance(to coordinates: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let currentLocation = locationManager.location else {return nil}
        
        let latitude = coordinates.latitude
        let longitude = coordinates.longitude
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        return location.distance(from: currentLocation)
    }
    
    @IBAction func changedRecyclingType(_ sender: UISegmentedControl) {
        let recyclingTypes = ["glass", "paper", "textiles", "electronics"]
        self.selectedRecyclingType = RecyclingType(rawValue: recyclingTypes[sender.selectedSegmentIndex])
        
        addAnnotationsToMap()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewMapTable" {
            let mapTableViewController = segue.destination as! MapTableViewController
            mapTableViewController.selectedMapPins = selectedRecyclingLocations
            mapTableViewController.selectedRecyclingType = selectedRecyclingType
        } else if segue.identifier == "MapPinSelected" {
            guard let selectedLocation = self.selectedLocation else {return}
            
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.selectedMapPin = selectedLocation
        }
    }
    
    @objc func goToDifferentView(notification: NSNotification) {
        guard let location = notification.userInfo?["location"] as? UIButtonLocation else {return}
        self.selectedLocation = location.location
        self.performSegue(withIdentifier: "MapPinSelected", sender: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        userLocationController.checkLocationSerivces { (success) in
            if success {
                self.centerMapOnUser()
            } else {
                self.errorAlertController.showErrorAlertView(in: self, with: "Location Not Found", and: "Could not retrive your current location. Please check your settings.")
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func registerForAnnotationViewClasses() {
        mapView.register(RecyclingAnnotation.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterMarker.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let cluster = view.annotation as? MKClusterAnnotation {
            mapView.showAnnotations(cluster.memberAnnotations, animated: true)
        }
    }
    
}
