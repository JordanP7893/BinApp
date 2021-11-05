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
    
    var selectedMapPins: [MapPin]?
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
        guard let mapPins = selectedMapPins else {return 0}
        return mapPins.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)

        let index = indexPath.row
        
        guard let mapPins = selectedMapPins else {return cell}
        let mapPin = mapPins[index]
        
        cell.textLabel?.text = mapPin.title
        cell.detailTextLabel?.text = mapPin.subtitle
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectTableCell" {
            guard let mapPins = selectedMapPins else {return}
            
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedPin = mapPins[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.selectedMapPin = selectedPin
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
