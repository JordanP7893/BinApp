//
//  Constants.swift
//  BinApp
//
//  Created by Jordan Porter on 08/06/2025.
//  Copyright © 2025 Jordan Porter. All rights reserved.
//

import Foundation

struct AppConfig {
    static let recyclingLocationsUrl = URL(string: "https://datamillnorth.org/download/bring-sites/53d959b8-f711-4b5b-9c91-94879122d87e/Copy%20of%20Bring%20Sites%20Master%20Sheet%20.csv")!
    static let getAddressUrl = URL(string: "https://bins.azurewebsites.net/api/getaddress")!
    static let getCollectionsUrl = URL(string: "https://bins.azurewebsites.net/api/getcollections")!
}
