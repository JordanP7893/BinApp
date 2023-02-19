//
//  BinAppUITests.swift
//  BinAppUITests
//
//  Created by Jordan Porter on 19/02/2023.
//  Copyright © 2023 Jordan Porter. All rights reserved.
//

import XCTest

final class BinAppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        app.launchArguments.append("--binScreenshots")
    }

    override func tearDownWithError() throws {
    }

    func testMakeScreenshot() throws {
        app.launch()


        let app = XCUIApplication()
        takeScreenshot(named: "Bin List")
        app.tables.cells.staticTexts["Green"].firstMatch.tap()
        takeScreenshot(named: "Green Bin")
        app.navigationBars.buttons.firstMatch.tap()
        app.navigationBars.firstMatch.children(matching: .button).matching(identifier: "Item").element(boundBy: 1).tap()
        takeScreenshot(named: "Notifications")
        app.navigationBars["Notifications"].buttons["Done"].tap()
        app.tabBars["Tab Bar"].buttons["Recycling Centres"].tap()
        app.buttons["Tracking"].tap()
        _ = app.maps.element.otherElements["ITV Yorkshire"].waitForExistence(timeout: 2)
        takeScreenshot(named: "Map")
        app.otherElements["ITV Yorkshire, Glass"].tap()
        app.buttons["More Info"].tap()
        _ = app.buttons["Directions"].waitForExistence(timeout: 1)
        takeScreenshot(named: "Recycling Info")
    }

    func takeScreenshot(named name: String) {
        let fullScreenshot = XCUIScreen.main.screenshot()

        let screenshotAttachment = XCTAttachment(
            uniformTypeIdentifier: "public.png",
            name: "Screenshot-\(UIDevice().name)-\(name).png",
            payload: fullScreenshot.pngRepresentation
        )

        screenshotAttachment.lifetime = .keepAlways
        add(screenshotAttachment)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
