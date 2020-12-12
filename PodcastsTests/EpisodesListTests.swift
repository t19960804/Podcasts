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

    let viewModel = EpisodesListViewModel()
    
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
    
    func testEpisodeCellViewModel_EmptyRSSFeedItem(){
        //測試item為空
        let item = RSSFeedItem()
        let episode = Episode(item: item)
        let episodeCellViewModel = EpisodeCellViewModel(episode: episode)
        XCTAssertEqual(episodeCellViewModel.title, "unknow title")
        XCTAssertEqual(episodeCellViewModel.author, "unknow author")
        XCTAssertEqual(episodeCellViewModel.imageUrl, URL(string: "unknow imageURL"))
        XCTAssertEqual(episodeCellViewModel.audioUrl, URL(string: "unknow audioUrl"))
        XCTAssertEqual(episodeCellViewModel.publishDateString, "Dec 12,2020")
        XCTAssertEqual(episodeCellViewModel.duration, "16:39")
    }
    func testEpisodeCellViewModel_MockRSSFeedItem(){
        //測試item有值
        let item2 = RSSFeedItem()
        item2.title = "My Experiences in Computer Science Vs Real World"
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 2
        dateComponents.day = 8
        dateComponents.hour = 9
        dateComponents.minute = 22
        dateComponents.second = 55
        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        let someDateTime = userCalendar.date(from: dateComponents)
        item2.pubDate = someDateTime
        
        let itunes = ITunesNamespace()
        itunes.iTunesImage = ITunesImage()
        itunes.iTunesImage?.attributes = .none
        let enclosure = RSSFeedItemEnclosure()
        enclosure.attributes = .none
        item2.enclosure = enclosure
        item2.iTunes = itunes
        
        item2.iTunes?.iTunesDuration = 573
        item2.iTunes?.iTunesImage?.attributes?.href = "https://i1.sndcdn.com/avatars-000403867065-5g5khr-original.jpg"
        item2.iTunes?.iTunesAuthor = "Brian Voong"
        item2.enclosure?.attributes?.url = "https://feeds.soundcloud.com/stream/396259545-brian-hong-voong-my-experiences-in-computer-science-vs-real-world.mp3"
        
        let episode2 = Episode(item: item2)
        let episodeCellViewModel2 = EpisodeCellViewModel(episode: episode2)
        XCTAssertEqual(episodeCellViewModel2.title, "My Experiences in Computer Science Vs Real World")
        XCTAssertEqual(episodeCellViewModel2.author, "Brian Voong")
        //attributes無法初始化,所以為nil
        XCTAssertEqual(episodeCellViewModel2.imageUrl, URL(string: "unknow imageURL"))
        XCTAssertEqual(episodeCellViewModel2.audioUrl, URL(string: "unknow audioUrl"))
        XCTAssertEqual(episodeCellViewModel2.publishDateString, "Feb 08,2018")
        XCTAssertEqual(episodeCellViewModel2.duration, "09:33")
    }
    func testTableViewFooterHeight_Searched_EmptyResult(){
        //FooterHeight > 顯示No Episodes!的Label
        //搜尋完沒有任何結果
        viewModel.episodes = []
        viewModel.isSearching = false
        viewModel.calculateFooterHeight()
        XCTAssertEqual(viewModel.footerHeight, 200)
    }
    func testTableViewFooterHeight_Searched_MockResult(){
        //搜尋完有結果
        let item = RSSFeedItem()
        let episode = Episode(item: item)
        let episodeCellViewModel = EpisodeCellViewModel(episode: episode)
        viewModel.episodes = [episodeCellViewModel,episodeCellViewModel,episodeCellViewModel]
        viewModel.isSearching = false
        viewModel.calculateFooterHeight()
        XCTAssertEqual(viewModel.footerHeight, 0)
    }
    func testTableViewFooterHeight_Searching(){
        //搜尋中,暫時沒有結果
        viewModel.episodes = []
        viewModel.isSearching = true
        viewModel.calculateFooterHeight()
        XCTAssertEqual(viewModel.footerHeight, 0)
    }
    func testGetEpisodeIndex_NilEpisode(){
        //episode傳入nil
        viewModel.episodes = []
        let index = viewModel.getEpisodeIndex(episode: nil)
        XCTAssertNil(index)
    }
    func testGetEpisodeIndex_UnexistEpisode(){
        //傳入不存在的Episode
        viewModel.episodes = []
        let targetEpisode = EpisodeCellViewModel(title: "Test title",author: "Test author")
        let index = viewModel.getEpisodeIndex(episode: targetEpisode)
        XCTAssertNil(index)
    }
    func testGetEpisodeIndex_MockEpisode(){
        viewModel.episodes.append(EpisodeCellViewModel(title: "Ep1", author: "Tony"))
        viewModel.episodes.append(EpisodeCellViewModel(title: "Ep2", author: "Tony"))
        viewModel.episodes.append(EpisodeCellViewModel(title: "Ep3", author: "Tony"))
        
        let targetEpisode = EpisodeCellViewModel(title: "Ep2",author: "Tony")
        let index = viewModel.getEpisodeIndex(episode: targetEpisode)
        XCTAssertEqual(index, 1)
    }
}
