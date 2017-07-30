//
//  YoyoUITests.swift
//  YoyoUITests
//
//  Created by Essam Nabil on 27/07/2017.
//  Copyright © 2017 Lightsome Apps. All rights reserved.
//

import XCTest
@testable import Yoyo

class YoyoUITests: XCTestCase {
        
    override func setUp()
    {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIfTrendingMoviesAppearInTableView()
    {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let numberofcells = tablesQuery.element(boundBy: 0).cells.count
        XCTAssertEqual(numberofcells, 49)
    }
    func testIfMovieDetailsAppearInUIViewController()
    {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let MovieTable = tablesQuery.element(boundBy: 0)
        MovieTable.cells.element(boundBy: 0).tap()
        let Moviewebview = app.webViews.count
        let Buttons = app.buttons.count
        XCTAssertEqual(Moviewebview, 1)
        XCTAssertEqual(Buttons, 2)
    }
    func testIfCastDetailsAppearInTableView()
    {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let MovieTable = tablesQuery.element(boundBy: 0)
        MovieTable.cells.element(boundBy: 0).tap()
        XCTAssertEqual(MovieTable.cells.count, 4)
    }
    func testWhenUserBrowsesMoviesWebsite()
    {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let MovieTable = tablesQuery.element(boundBy: 0)
        MovieTable.cells.element(boundBy: 0).tap()
        let BrowseWebsiteButton = app.buttons["View Movie's Website"]
        BrowseWebsiteButton.tap()
        let state = UIApplication.shared.applicationState
        XCTAssertEqual(state, .background)
    }
    func testWhenUserwatchesMovieTrailer()
    {
        let app = XCUIApplication()
        app.launch()
        let tablesQuery = app.tables
        let MovieTable = tablesQuery.element(boundBy: 0)
        MovieTable.cells.element(boundBy: 0).tap()
        let webViewQury:XCUIElementQuery = app.descendants(matching: .webView)
        let webView = webViewQury.element(boundBy: 0)
        XCTAssertEqual(webView.buttons.count, 0)
        webView.tap()
        sleep(2)
        app.windows.element(boundBy: 0).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8)).tap()
        sleep(2)
        XCTAssertEqual(webView.buttons.count, 2)
    }
    func testTheWholeApplication()
    {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let MovieTable = tablesQuery.element(boundBy: 0)
        var numberofcells = tablesQuery.element(boundBy: 0).cells.count
        XCTAssertEqual(numberofcells, 49)
        MovieTable.cells.element(boundBy: 0).tap()
        XCTAssertNotEqual(MovieTable.cells.count, 0)
        let BackKey = app.buttons["BackButton"]
        BackKey.tap()
        numberofcells = tablesQuery.element(boundBy: 0).cells.count
        XCTAssertNotEqual(numberofcells, 0)
    }
    
}
