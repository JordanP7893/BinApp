//
//  DetailTableViewController.swift
//  BinApp
//
//  Created by Jordan Porter on 17/02/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var mapPreview: UIImageView!
    @IBOutlet weak var mapActivityIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    let directionsController = DirectionDataController()
    
    var selectedLocation: RecyclingLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if let location = selectedLocation {
            let coordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            getMapImage(centeredOn: coordinates)
        }
        
    }
    
    func setupView() {
        mapActivityIndicator.isHidden = false
        mapActivityIndicator.startAnimating()
        
        if let location = selectedLocation {
            self.title = location.name
            
            let coordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            calculateETA(destination: coordinates)
            
            guard var addressText = location.address else {return}
            if let postcodeText = location.postcode {
                addressText = "\(addressText.trimmingCharacters(in: .whitespacesAndNewlines)), \(postcodeText)"
                addressText = addressText.replacingOccurrences(of: ", ", with: "\n")
            }
            
            titleLabel.text = location.typeDescription
            addressLabel.text = addressText
            getMapImage(centeredOn: coordinates)
        }
        
        directionsButton.titleLabel?.textAlignment = .center
        directionsButton.layer.cornerRadius = 10
        
    }
    
    func getMapImage(centeredOn coordinate: CLLocationCoordinate2D) {
        let options = MKMapSnapshotter.Options()
        options.size = CGSize(width: 120, height: 120)
        options.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        let snapShotter = MKMapSnapshotter(options: options)
        snapShotter.start { (snapshot, error) in
            guard error == nil else {
                return
            }
            
            if let snapshot = snapshot?.image  {
                DispatchQueue.main.async {
                    self.mapPreview.image = snapshot
                    self.mapActivityIndicator.stopAnimating()
                    self.mapActivityIndicator.isHidden = true
                }
            }
        }
        
        
    }

    func calculateETA(destination: CLLocationCoordinate2D) {
        guard let location = locationManager.location?.coordinate else { return }
        
        directionsController.getDirections(from: location, to: destination) { (firstRoute) in
            guard let firstRoute = firstRoute else {
                return
            }
            let travelDistanceInMetres = firstRoute.distance
            let travelDistance = (travelDistanceInMetres * 0.000621371).rounded(toPlaces: 1)
            
            let travelTimeInSeconds = firstRoute.expectedTravelTime
            let travelTime = Int((travelTimeInSeconds/60).rounded(.up))
            
            
            self.directionsButton.setTitle("Directions\n\(travelDistance) miles    \(travelTime) mins", for: .normal)
        }
    }
    
    @IBAction func NavigateButtonPressed(_ sender: UIButton) {
        guard let location = selectedLocation else { return }
        
        let coordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
}
