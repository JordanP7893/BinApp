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
    
    var allRecyclingLocations: [RecyclingLocation]?
    var tableViewRecyclingLocations: [RecyclingLocation]?
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
        getRecyclingLocations()
        
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
    
    func getRecyclingLocations() {
        if let locationData = locationDataController.getLocalLocationData() {
            self.calculateDistanceForLocations(locationData)
            self.addAnnotationsToMap()
        } else  {
            locationDataController.fetchLocations { (locations) in
                guard let locations = locations else {
                    self.errorAlertController.showErrorAlertView(in: self, with: "Location Not Found", and: "Could not retrive your current location. Please check your settings.")
                    return
                }
                DispatchQueue.main.async {
                    self.calculateDistanceForLocations(locations)
                    self.addAnnotationsToMap()
                }
            }
        }
    }
    
    private func calculateDistanceForLocations(_ locations: [RecyclingLocation]) {
        guard let currentLocation = locationManager.location else { return }
        
        allRecyclingLocations = locations.map { (location) -> RecyclingLocation in
            location.distance = distance(from: currentLocation, to: location.coordinates)
            return location
        }
    }
    
    private func convertToMapPins(_ locations: [RecyclingLocation]) -> [MapPin] {
        return locations.map { location in
            let mapPin = MapPin(coordinate: location.coordinates, title: location.name, subtitle: location.typeDescription, type: location.type, address: location.address, postcode: location.postcode)
            mapPin.distance = location.distance
            mapPin.drivingDistance = location.drivingDistance
            mapPin.drivingTime = location.drivingTime
            return mapPin
        }
    }
    
    private func convertToRecyclingLocation(_ pin: MapPin) -> RecyclingLocation {
        let location = RecyclingLocation(name: pin.title ?? "", type: pin.type, typeDescription: pin.subtitle ?? "", coordinates: pin.coordinate, address: pin.address, postcode: pin.postcode)
        location.distance = pin.distance
        location.drivingDistance = pin.drivingDistance
        location.drivingTime = pin.drivingTime
        return location
    }
    
    func addAnnotationsToMap() {
        guard let allRecyclingLocations = allRecyclingLocations else { return }
        guard let currentLocation = locationManager.location else { return }
            
        mapView.removeAnnotations(mapView.annotations)
        
        let filteredLocations = filterLocations(allRecyclingLocations, by: selectedRecyclingType)
        let sortedLocations = orderLocations(filteredLocations, asDistancefrom: currentLocation)
        
        let mapPins = convertToMapPins(sortedLocations)
        mapView.addAnnotations(mapPins)
        
        var count = 0
        self.tableViewRecyclingLocations = sortedLocations.filter { location in
            count += 1
            return count <= 10
        }
        calculateDrivingDistances(from: currentLocation)
    }
    
    private func calculateDrivingDistances(from currentLocation: CLLocation) {
        guard let recyclingLocations = tableViewRecyclingLocations else { return }
        
        let mapTableViewController = MapTableViewController()
        let dispatchGroup = DispatchGroup()
        
        for location in recyclingLocations {
            guard location.drivingDistance == nil else { continue }
            dispatchGroup.enter()
            self.directionsController.getDirections(from: currentLocation.coordinate, to: location.coordinates) { route in
                if let route = route {
                    location.drivingDistance = route.distance
                    location.drivingTime = route.expectedTravelTime
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let sortedRecyclingLocations = recyclingLocations.sorted { (location1, location2) -> Bool in
                guard let distance1 = location1.drivingDistance, let distance2 = location2.drivingDistance else { return false }
                return distance1 < distance2
            }
            self.tableViewRecyclingLocations = sortedRecyclingLocations
            
            DispatchQueue.main.async {
                mapTableViewController.tableView.reloadData()
            }
        }
    }
    
    func filterLocations(_ locations: [RecyclingLocation], by recyclingType: RecyclingType) -> [RecyclingLocation] {
        return locations.filter { location in
            location.type == recyclingType.description
        }
    }
    
    func orderLocations(_ locations: [RecyclingLocation], asDistancefrom currentLocation: CLLocation) -> [RecyclingLocation] {
        
        let sortedMapPins = locations.sorted { (location1, location2) -> Bool in
            guard let distance1 = location1.distance, let distance2 = location2.distance else { return false }
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

        let filteredLocations = filterLocations(allRecyclingLocations, by: selectedRecyclingType)
        let orderedMapPins = orderLocations(filteredLocations, asDistancefrom: centerOfMap)
        
        let furthestPinInRegion = orderedMapPins[4]
        print(furthestPinInRegion.name)
        let furthestPinLatitude = CLLocation(latitude: furthestPinInRegion.coordinates.latitude, longitude: 0)
        let furthestPinLongitude = CLLocation(latitude: 0, longitude: furthestPinInRegion.coordinates.longitude)
        
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
            mapTableViewController.selectedRecyclingLocations = tableViewRecyclingLocations
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
