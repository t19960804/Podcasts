//
//  NetworkServiceTests.swift
//  PodcastsTests
//
//  Created by t19960804 on 1/3/21.
//  Copyright © 2021 t19960804. All rights reserved.
//

import XCTest
@testable import Podcasts

class NetworkServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }
    //MARK: - FetchPodcasts
    func testFetchPodcasts_CompleteSearchText(){
        let expectation = XCTestExpectation(description: "Try to parse XML from url")

        let searchText = "Voong"
        var error: Error?
        var podcastsResult: [Podcast]?
        
//        NetworkService.sharedInstance.fetchPodcasts(searchText: searchText) { (result) in
//            switch result {
//            case .failure(let err):
//                error = err
//            case .success(let podcasts):
//                podcastsResult = podcasts
//            }
//            expectation.fulfill()
//        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error, "Fetch podcast failed:\(error!)")
        XCTAssertNotNil(podcastsResult, "Fetch podcast success, but podcastsResult should not be nil")
    }
    func testFetchPodcasts_EmptySearchText(){
        let expectation = XCTestExpectation(description: "Try to parse XML from url")

        let searchText = ""
        var error: Error?
        var podcastsResult: [Podcast]?
        
//        NetworkService.sharedInstance.fetchPodcasts(searchText: searchText) { (result) in
//            switch result {
//            case .failure(let err):
//                error = err
//            case .success(let podcasts):
//                podcastsResult = podcasts
//            }
//            expectation.fulfill()
//        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error, "Fetch podcast failed:\(error!)")
        XCTAssertNotNil(podcastsResult, "Fetch podcast success, but podcastsResult should not be nil")
        XCTAssertEqual(podcastsResult?.count, 0)
    }
    //MARK: - FetchEpisodes
    func testFetchEpisodes_CompleteSearchText(){
        let expectation = XCTestExpectation(description: "Try to fetch episodes from url")
        let urlString = "https://feeds.soundcloud.com/users/soundcloud:users:114798578/sounds.rss"
        var error: Error?
        var episodesResult: [Episode]?
//        NetworkService.sharedInstance.fetchEpisodes(url: URL(string: urlString)!) { (result) in
//            switch result {
//            case .failure(let err):
//                error = err
//            case .success(let episodes):
//                episodesResult = episodes
//            }
//            expectation.fulfill()
//        }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error, "Fetch episodes failed:\(error!)")
        XCTAssertNotNil(episodesResult, "Fetch success, but episodesResult should not be nil")
    }
}
