//
//  ClusterMarker.swift
//  BinApp
//
//  Created by Jordan Porter on 03/02/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import MapKit

class ClusterMarker: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            if let cluster = newValue as? MKClusterAnnotation {
                for marker in cluster.memberAnnotations {
                    if let marker = marker as? MapPin {
                        markerTintColor = marker.color
                    }
                }
            }
        }
    }
    
    
}
