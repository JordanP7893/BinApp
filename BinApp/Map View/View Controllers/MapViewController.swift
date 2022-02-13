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
    var selectedRecyclingLocations: [RecyclingLocation]?
    var selectedRecyclingType = RecyclingType(rawValue: "glass")
    var selectedLocation: RecyclingLocation?
    
    let locationDataController = LocationDataController()
    let locationManager = CLLocationManager()
    let directionsController = DirectionDataController()
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
    
    private func convertToRecyclingLocation(_ pin: MapPin) -> RecyclingLocation {
        let location = RecyclingLocation(name: pin.title ?? "", type: pin.type, typeDescription: pin.subtitle ?? "", longitude: pin.coordinate.longitude, latitude: pin.coordinate.latitude, address: pin.address, postcode: pin.postcode)
        return location
    }
    
    private func retrieveLocationsFrom(_ sortedMapPins: [MapPin], upTo maxNumberOfPins: Int) -> [RecyclingLocation] {
        var count = 0
        var locations: [RecyclingLocation] = []
        for pin in sortedMapPins {
            if count < maxNumberOfPins {
                let location = convertToRecyclingLocation(pin)
                locations.append(location)
            }
            count += 1
        }
        return locations
    }
    
    func addAnnotationsToMap() {
        guard let currentLocation = locationManager.location else {return}
        
        if let allRecyclingLocions = allRecyclingLocations {
            mapView.removeAnnotations(allRecyclingLocions)
            
            guard let sortedMapPins = orderMap(pins: allRecyclingLocions, asDistancefrom: currentLocation) else {return}
            
            let locations = retrieveLocationsFrom(sortedMapPins, upTo: 10)
            
            self.selectedRecyclingLocations = locations
            mapView.addAnnotations(sortedMapPins)
            calculateDrivingDistances(from: currentLocation)
        }
    }
    
    private func calculateDrivingDistances(from currentLocation: CLLocation) {
        guard let recyclingLocations = selectedRecyclingLocations else { return }
        
        let mapTableViewController = MapTableViewController()
        let dispatchGroup = DispatchGroup()
        
        for location in recyclingLocations {
            if let locationDistance = location.distance {
                print(locationDistance)
            }
            dispatchGroup.enter()
            let coordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            self.directionsController.getDirections(from: currentLocation.coordinate, to: coordinates) { route in
                if let route = route {
                    location.distance = route.distance
                    print(route.distance)
                }
                print(location.name)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("notify")
            let sortedRecyclingLocations = recyclingLocations.sorted { (location1, location2) -> Bool in
                guard let distance1 = location1.distance, let distance2 = location2.distance else { return false }
                return distance1 < distance2
            }
            self.selectedRecyclingLocations = sortedRecyclingLocations
            
            DispatchQueue.main.async {
                mapTableViewController.tableView.reloadData()
            }
        }
    }
    
    func orderMap(pins: [MapPin], asDistancefrom location: CLLocation) -> [MapPin]? {
        var recyclingMapPins: [MapPin] = []
        
        for pin in pins {
            if pin.type == selectedRecyclingType.description {
                pin.distance = distance(from: location, to: pin.coordinate)
                recyclingMapPins.append(pin)
            }
        }
        
        let sortedMapPins = recyclingMapPins.sorted { (pin1, pin2) -> Bool in
            guard let distance1 = pin1.distance, let distance2 = pin2.distance else { return false }
            return distance1 < distance2
        }
        
        return sortedMapPins
    }
    
    func distance(from location: CLLocation, to coordinates: CLLocationCoordinate2D) -> CLLocationDistance? {
        let latitude = coordinates.latitude
        let longitude = coordinates.longitude
        
        let pinLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        return location.distance(from: pinLocation)
    }
    
    func zoomMapOnNewRegion() {
        let centerOfMap = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        guard let allRecyclingLocations = allRecyclingLocations else {return}

        guard let orderedMapPins = orderMap(pins: allRecyclingLocations, asDistancefrom: centerOfMap) else {return}
        
        let furthestPinInRegion = orderedMapPins[4]
        let furthestPinLatitude = CLLocation(latitude: furthestPinInRegion.coordinate.latitude, longitude: 0)
        let furthestPinLongitude = CLLocation(latitude: 0, longitude: furthestPinInRegion.coordinate.longitude)
        
        let centerOfMapLatitude = CLLocation(latitude: centerOfMap.coordinate.latitude, longitude: 0)
        let centerOfMapLongitude = CLLocation(latitude: 0, longitude: centerOfMap.coordinate.longitude)
        
        let latitudeDistance = centerOfMapLatitude.distance(from: furthestPinLatitude)
        let longitudeDistance = centerOfMapLongitude.distance(from: furthestPinLongitude)
        
        let region = MKCoordinateRegion(center: centerOfMap.coordinate, latitudinalMeters: latitudeDistance * 1.9, longitudinalMeters: longitudeDistance * 1.9)
        mapView.userTrackingMode = .none
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func changedRecyclingType(_ sender: UISegmentedControl) {
        let recyclingTypes = ["glass", "paper", "textiles", "electronics"]
        self.selectedRecyclingType = RecyclingType(rawValue: recyclingTypes[sender.selectedSegmentIndex])
        
        addAnnotationsToMap()
        zoomMapOnNewRegion()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewMapTable" {
            let mapTableViewController = segue.destination as! MapTableViewController
            mapTableViewController.selectedRecyclingLocations = selectedRecyclingLocations
            mapTableViewController.selectedRecyclingType = selectedRecyclingType
        } else if segue.identifier == "MapPinSelected" {
            guard let selectedLocation = sender as? RecyclingLocation else {return}
            
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.selectedLocation = selectedLocation
        }
    }
    
    @objc func goToDifferentView(notification: NSNotification) {
        guard let detailButton = notification.userInfo?["location"] as? UIButtonLocation, let mapPin = detailButton.mapPin else {return}
        let location = convertToRecyclingLocation(mapPin)
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
