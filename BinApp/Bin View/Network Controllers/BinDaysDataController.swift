//
//  BinDaysDataController.swift
//  BinApp
//
//  Created by Jordan Porter on 09/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation


class BinDaysDataController {
    
    func fetchBinDates(id: Int, completion: @escaping ([BinDays]?) -> Void) {
        let binDatesUrl = URL(string: "https://imactivate.com/leedsbinsfeedback/returnDatesDataNew.php")!
        var success = false
        
        BinAddressDataController.callPost(url: binDatesUrl, params: ["premisesID": id]) { message, data in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                if !success {
                    completion(nil)
                }
            })
            
            if let jsonData = data {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                formatter.timeZone = TimeZone.current
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(formatter)
                
                do {
                    let binDates = try decoder.decode([BinDays].self, from: jsonData)
                    self.saveBinData(binDates)
                    success = true
                    completion(binDates)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func saveBinData(_ binDays: [BinDays]) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("bin_data").appendingPathExtension("plist")
        
        if FileManager.default.fileExists(atPath: archiveURL.path){
            try? FileManager.default.removeItem(atPath: archiveURL.path)
        }
        
        let propertyListEncoder = PropertyListEncoder()
        let encodedBinDays = try? propertyListEncoder.encode(binDays)
        try? encodedBinDays?.write(to: archiveURL, options: .noFileProtection)
    }
    
    func fetchBinData() -> [BinDays]? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("bin_data").appendingPathExtension("plist")
        
        guard (archiveURL.isThisURL(lessThanDaysOld: 7)) else { return nil }
        
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedBinDays = try? Data(contentsOf: archiveURL), let decodedBinDays = try? propertyListDecoder.decode([BinDays].self, from: retrievedBinDays){
            return decodedBinDays
        } else {
            return nil
        }
    }
    
}
