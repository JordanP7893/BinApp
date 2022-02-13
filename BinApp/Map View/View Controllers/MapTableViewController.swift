//
//  MapTableViewController.swift
//  BinApp
//
//  Created by Jordan Porter on 10/02/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewController: UITableViewController {

    let recyclingMarker = RecyclingAnnotation()
    
    var selectedRecyclingLocations: [RecyclingLocation]?
    var selectedRecyclingType: RecyclingType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let recyclingType = selectedRecyclingType else {return}
        self.title = recyclingType.description.capitalized
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let mapPins = selectedRecyclingLocations else {return 0}
        return mapPins.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)

        let index = indexPath.row
        
        guard let selectedRecyclingLocations = selectedRecyclingLocations else {return cell}
        let recyclingLocation = selectedRecyclingLocations[index]
        
        cell.textLabel?.text = recyclingLocation.name
        if let distance = recyclingLocation.distance {
            let travelDistanceInMetres = distance
            let travelDistance = (travelDistanceInMetres * 0.000621371).rounded(toPlaces: 1)
            
            cell.detailTextLabel?.text = String("\(travelDistance) miles")
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectTableCell" {
            guard let selectedRecyclingLocations = selectedRecyclingLocations else {return}
            
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedLocation = selectedRecyclingLocations[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.selectedLocation = selectedLocation
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
