//
//  BinTypeListData.swift
//  BinApp
//
//  Created by Jordan Porter on 07/11/2022.
//  Copyright © 2022 Jordan Porter. All rights reserved.
//

import Foundation

class BinTypeListData {
    var binTypeList: [String: BinTypeList]
    
    init() {
        let url = Bundle.main.url(forResource: "bin_list", withExtension: "plist")
        let data = try! Data(contentsOf: url!)
        self.binTypeList = try! PropertyListDecoder().decode([String: BinTypeList].self, from: data)
    }
}

struct BinTypeList: Decodable {
    var yes: String = ""
    var no: String = ""
}
