//
//  RecyclingMarker.swift
//  BinApp
//
//  Created by Jordan Porter on 07/12/2019.
//  Copyright © 2019 Jordan Porter. All rights reserved.
//

import MapKit
import UIKit

class RecyclingAnnotation: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            if let mapPin = newValue as? MapPin {
                clusteringIdentifier = mapPin.type
                glyphImage = UIImage(named: mapPin.type)
                markerTintColor = mapPin.color
                canShowCallout = true
                let button  = UIButtonLocation(type: .detailDisclosure)
                button.location = mapPin
                button.addTarget(self, action: #selector(directionButtonPressed), for: .touchUpInside)
                rightCalloutAccessoryView = button
            }
        }
    }
    
    @objc func directionButtonPressed(_ sender: UIButtonLocation) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DetailButtonPressed"), object: nil, userInfo: ["location":sender])
    }
}

class UIButtonLocation: UIButton {
    var location: MapPin?
}

class MapPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: String
    var address: String?
    var postcode: String?
    var color: UIColor {
        switch type {
        case "glass":
            return UIColor(red: 96/255, green: 194/255, blue: 183/255, alpha: 1)
        case "paper":
            return UIColor(red: 22/255, green: 137/255, blue: 206/255, alpha: 1)
        case "electronics":
            return UIColor(red: 223/255, green: 20/255, blue: 123/255, alpha: 1)
        default:
            return UIColor(red: 251/255, green: 183/255, blue: 49/255, alpha: 1)
        }
    }
    var distance: Double?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: String, address: String?, postcode: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.address = address
        self.postcode = postcode
    }
}
