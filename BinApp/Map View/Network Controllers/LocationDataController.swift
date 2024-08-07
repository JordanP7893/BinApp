//
//  LocationDataController.swift
//  BinApp
//
//  Created by Jordan Porter on 15/04/2019.
//  Copyright © 2019 Jordan Porter. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationDataController {
    
    func fetchLocations(completion: @escaping ([RecyclingLocation]?) -> Void) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("recycling_data").appendingPathExtension("plist")
        
        let urlString = "https://datamillnorth.org/download/bring-sites/53d959b8-f711-4b5b-9c91-94879122d87e/Copy%20of%20Bring%20Sites%20Master%20Sheet%20.csv"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error ==  nil, let string = String(data:data, encoding: .ascii) else { return }
            
            let csv = CSwiftV(with: string)
        
            guard let keyedRows = csv.keyedRows else {return}
            
            var locations: [RecyclingLocation] = []
            
            for row in keyedRows {
                guard let name = row["Site Name"], let longitudeString = row["Longitude"], let latitudeString = row["Latitude"]  else {continue}
                let address = row["Address"]
                let postcode = row["Post Code"]
                let glass = row["Recyclables-Mixed Glass"] == "Y" ? true : false
                let paper = row["Recyclables-Paper"] == "Y" ? true : false
                let textiles = row["Recyclables-Textiles"] == "Y" ? true : false
                let electronics = row["Recyclables Small Electrical"] == "Y" ? true : false
                
                guard var longitude = Double(longitudeString), let latitude = Double(latitudeString) else {continue}
                
                //Fix for incorrect longitudes
                longitude = longitude > 0 ? -longitude : longitude
                
                let locationTypes = ["glass" : glass, "paper" : paper, "textiles" : textiles, "electronics" : electronics]
                
                var descriptions: [String] = []
                for type in locationTypes {
                    if type.value {
                        descriptions.append(type.key.capitalized)
                    }
                }
                
                let typeDescription = descriptions.joined(separator: ", ")
                
                for type in locationTypes {
                    if type.value {
                        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let location = RecyclingLocation(name: name, type: type.key, typeDescription: typeDescription, coordinates: coordinates, address: address, postcode: postcode)
                        
                        locations.append(location)
                    }
                }
            }
            if FileManager.default.fileExists(atPath: archiveURL.path){
                try? FileManager.default.removeItem(atPath: archiveURL.path)
            }
            
            let propertyListEncoder = PropertyListEncoder()
            let encodedLocations = try? propertyListEncoder.encode(locations)
            try? encodedLocations?.write(to: archiveURL, options: .noFileProtection)
            
            return completion(locations)
        }
        task.resume()
    }
    
    func getLocalLocationData() -> [RecyclingLocation]? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("recycling_data").appendingPathExtension("plist")
        
        guard (archiveURL.isThisURL(lessThanDaysOld: 28)) else { return nil }
        
        let propertyListDecoder = PropertyListDecoder()
        
        if let retrievedLocations = try? Data(contentsOf: archiveURL), let decodedLocations = try? propertyListDecoder.decode([RecyclingLocation].self, from: retrievedLocations){
            return decodedLocations
        } else {
            return nil
        }
    }
    
}

extension Date {
    func addDay(noOfDays: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: noOfDays, to: self)!
    }
}

extension URL {
    func isThisURL(lessThanDaysOld: Int) -> Bool {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: self.path) as [FileAttributeKey: Any],
            let creationDate = attributes[FileAttributeKey.creationDate] as? Date {

            if creationDate.addDay(noOfDays: lessThanDaysOld) > Date() {
                return true
            }
        }
        return false
    }
}

extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}
