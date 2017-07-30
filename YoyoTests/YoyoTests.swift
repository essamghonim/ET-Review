//
//  YoyoTests.swift
//  YoyoTests
//
//  Created by Essam Nabil on 27/07/2017.
//  Copyright © 2017 Lightsome Apps. All rights reserved.
//

import XCTest
@testable import Yoyo

class YoyoTests: XCTestCase
{
    
    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRetreivalOfMoviesFromAPI()
    {
        let expect = expectation(description: "It retrieves the movies from the API and runs the callback closure")
        let MainController = MainViewController()
        MainController.GetMovies(completionHandler: { (success) -> Void in
            
            XCTAssertEqual(MainController.MovieNames.count, 49)
            XCTAssertEqual(MainController.MovieTrailer.count, 49)
            XCTAssertEqual(MainController.VideoImagesLink.count, 49)
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    func testRetreivalOfMoviesFromFile()
    {
        let MainController = MainViewController()
        MainController.ReadMoviesFromFile()
        XCTAssertEqual(MainController.MovieNames.count, 49)
        XCTAssertEqual(MainController.MovieTrailer.count, 49)
        XCTAssertEqual(MainController.VideoImagesLink.count, 49)
    }
    func testRetreivalOfCompressionOfImages()
    {
        let testImage = UIImage(named: "BackButton")
        let OriginalImageData = UIImagePNGRepresentation(testImage!)! as NSData
        let imagedata = MainViewController.compressImage(image: testImage!, compressionQuality: 0.1, append: false)
        XCTAssertGreaterThan(OriginalImageData.length, imagedata.length)
    }
    func testRetreivalOfMovieDetails()
    {
        let expect = expectation(description: "It retrieves the movies from the API and runs the callback closure")
        let MainController = MainViewController()
        let MovieController = MovieDetailsController()
        MainController.GetMovies(completionHandler: { (success) -> Void in
            
            MovieDetailsController.MovieDetails = MainController.MoviesArray[0] as! NSDictionary
            MovieController.RetrievePageDetails()
            XCTAssertNotEqual(MovieController.MovieName, "")
            XCTAssertNotEqual(MovieController.CastName.count, 0)
            XCTAssertNotEqual(MovieController.CastJob.count, 0)
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    func testRetreivalOfCastDetailsFromAPI()
    {
        let MovieController = MovieDetailsController()
        let expect = expectation(description: "It retrieves the cast details from the API and runs the callback closure")
        MovieController.GetCast(ID: "tt3521164", completionHandler: { (success) -> Void in
            
            XCTAssertNotEqual(MovieController.CastName.count, 0)
            XCTAssertNotEqual(MovieController.CastJob.count, 0)
            XCTAssertNotEqual(MovieController.CastImageLink.count, 0)
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    func testRetreivalOfCastDetailsFromFile()
    {
        let MovieController = MovieDetailsController()
        MovieController.MovieName = "The Boss baby"
        let CheckIfRetrievedFromFile = MovieController.readCastFile()
        XCTAssertNotEqual(MovieController.CastName.count, 0)
        XCTAssertNotEqual(MovieController.CastJob.count, 0)
        XCTAssertEqual(CheckIfRetrievedFromFile, true)
    }
    func testIfUserIsBrowsingOffline()
    {
        let CheckIfUserOffline =  Reachability.isConnectedToNetwork()
        XCTAssertEqual(CheckIfUserOffline, true)
    }
    func testingTheWholeFunctionalityFirstScenario()
    {
        let expect = expectation(description: "It retrieves the movies from the API and runs the callback closure")
        let MainController = MainViewController()
        let MovieController = MovieDetailsController()
        MainController.GetMovies(completionHandler: { (success) -> Void in
            XCTAssertEqual(MainController.MovieNames.count, 49)
            XCTAssertEqual(MainController.MovieTrailer.count, 49)
            XCTAssertEqual(MainController.VideoImagesLink.count, 49)
            MovieDetailsController.MovieDetails = MainController.MoviesArray[0] as! NSDictionary
            MovieController.RetrievePageDetails()
            XCTAssertNotEqual(MovieController.MovieName, "")
            XCTAssertNotEqual(MovieController.CastName.count, 0)
            XCTAssertNotEqual(MovieController.CastJob.count, 0)
            XCTAssertNotEqual(MovieController.MovieWebsite, "")
            expect.fulfill()
        })
        waitForExpectations(timeout: 10, handler: nil)
    }
    func testingTheWholeFunctionalitySecondScenario()
    {
        let MainController = MainViewController()
        let MovieController = MovieDetailsController()
        MainController.ReadMoviesFromFile()
        XCTAssertEqual(MainController.MovieNames.count, 49)
        XCTAssertEqual(MainController.MovieTrailer.count, 49)
        XCTAssertEqual(MainController.VideoImagesLink.count, 49)
        MovieDetailsController.MovieDetails = MainController.MoviesArray[0] as! NSDictionary
        let CheckIfRetrievedFromFile = MovieController.readCastFile()
        XCTAssertNotEqual(MovieController.CastName.count, 0)
        XCTAssertNotEqual(MovieController.CastJob.count, 0)
        XCTAssertEqual(CheckIfRetrievedFromFile, true)
    }
    func testingTheWholeFunctionalityThirdScenario()
    {
        let MainController = MainViewController()
        let MovieController = MovieDetailsController()
        MainController.ReadMoviesFromFile()
        XCTAssertEqual(MainController.MovieNames.count, 49)
        XCTAssertEqual(MainController.MovieTrailer.count, 49)
        XCTAssertEqual(MainController.VideoImagesLink.count, 49)
        MovieDetailsController.MovieDetails = MainController.MoviesArray[0] as! NSDictionary
        MovieController.RetrievePageDetails()
        XCTAssertNotEqual(MovieController.MovieName, "")
        XCTAssertNotEqual(MovieController.CastName.count, 0)
        XCTAssertNotEqual(MovieController.CastJob.count, 0)
        XCTAssertNotEqual(MovieController.MovieWebsite, "")
    }
    func testPerformanceTimeForRetreivalOfMoviesFromAPI()
    {
        self.measure
        {
            let MainController = MainViewController()
            MainController.GetMovies(completionHandler: { (success) -> Void in
            })
        }
    }
    func testPerformanceTimeForRetreivalOfMoviesFromFile()
    {
        self.measure
        {
                let MainController = MainViewController()
                MainController.ReadMoviesFromFile()
        }
    }
    func testPerformanceTimeForCompressionOfImages()
    {
        self.measure
        {
                let testImage = UIImage(named: "BackButton")
                let OriginalImageData = UIImagePNGRepresentation(testImage!)! as NSData
                let imagedata = MainViewController.compressImage(image: testImage!, compressionQuality: 0.1, append: false)
                XCTAssertGreaterThan(OriginalImageData.length, imagedata.length)
        }
    }
    func testPerformanceTimeForRetreivalOfMovieDetails()
    {
        self.measure
            {
                let MainController = MainViewController()
                let MovieController = MovieDetailsController()
                MainController.GetMovies(completionHandler: { (success) -> Void in
                    
                    MovieDetailsController.MovieDetails = MainController.MoviesArray[0] as! NSDictionary
                    MovieController.RetrievePageDetails()
                })
                
        }
    }
    func testPerformanceTimeForRetreivalOfCastDetailsFromFile()
    {
        self.measure
        {
                let MovieController = MovieDetailsController()
                let CheckIfRetrievedFromFile = MovieController.readCastFile()
                XCTAssertEqual(CheckIfRetrievedFromFile, true)
        }
    }
    
}
