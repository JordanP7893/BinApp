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

struct HelpUrls {
    static let cannotFindAddressUrl = URL(string: "https://forms.leeds.gov.uk/CannotFindYourAddress/")!
    static let binDayIncorrectUrl = URL(string: "https://forms.leeds.gov.uk/BinDaysNotShowingOrIncorrect/")!
    static let missedCollectionUrl = URL(string: "https://www.leeds.gov.uk/bins-and-recycling/your-bins/bin-collection-problems")!
    static let generalEnquiryUrl = URL(string: "https://www.leeds.gov.uk/bins-and-recycling")!
    
    static var email: URL {
        let subject = "Bins and Recycling - Bug Report"
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
        let body = "\n\n--------------------\nApp Version: \(appVersion) (\(buildNumber))"
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? body
        let urlString = "mailto:noun-dioxide-0u@icloud.com?subject=\(encodedSubject)&body=\(encodedBody)"
        return URL(string: urlString)!
    }
    
    static let leaveReview = URL(string: "https://apps.apple.com/app/id1599887664?action=write-review")!
}

