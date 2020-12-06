//
//  PodcastsTests.swift
//  PodcastsTests
//
//  Created by t19960804 on 12/6/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import XCTest
import FeedKit

@testable import Podcasts
class EpisodesListTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testEpisodeCellViewModel(){
        let item = RSSFeedItem()
        let episode = Episode(item: item)
        let episodeCellViewModel = EpisodeCellViewModel(episode: episode)
        XCTAssertEqual(episodeCellViewModel.title, "unknow title")
        XCTAssertEqual(episodeCellViewModel.author, "unknow author")
        XCTAssertEqual(episodeCellViewModel.imageUrl, URL(string: "unknow imageURL"))
        XCTAssertEqual(episodeCellViewModel.audioUrl, URL(string: "unknow audioUrl"))
        XCTAssertEqual(episodeCellViewModel.publishDateString, "Dec 06,2020")
        XCTAssertEqual(episodeCellViewModel.duration, "16:39")
    }

}
