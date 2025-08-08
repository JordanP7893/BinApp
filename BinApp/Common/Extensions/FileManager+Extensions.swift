//
//  FileManager+Extensions.swift
//  BinApp
//
//  Created by Jordan Porter on 08/06/2025.
//  Copyright © 2025 Jordan Porter. All rights reserved.
//

import Foundation

extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}
