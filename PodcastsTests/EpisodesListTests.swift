//
//  PodcastsTests.swift
//  PodcastsTests
//
//  Created by t19960804 on 12/6/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import XCTest
import FeedKit
import Combine

@testable import Podcasts
class EpisodesListTests: XCTestCase {

    var viewModel: EpisodesListViewModel!
    var subscribers: Set<AnyCancellable>!
    
    override func setUp() { //set initial state before each test method is run.
        super.setUp()
        viewModel = EpisodesListViewModel()
        subscribers = Set<AnyCancellable>()
    }
    override func tearDown() { //perform cleanup after each test method completes.
        super.tearDown()
        viewModel = nil
        subscribers.removeAll()
    }
    //MARK: - Test EpisodeCellViewModel
    func testEpisodeCellViewModel_EmptyRSSFeedItem(){
        //測試item為空
        let item = RSSFeedItem()
        let episode = Episode(item: item)
        let episodeCellViewModel = EpisodeCellViewModel(episode: episode)
        XCTAssertEqual(episodeCellViewModel.title, "unknow title")
        XCTAssertEqual(episodeCellViewModel.author, "unknow author")
        XCTAssertEqual(episodeCellViewModel.imageUrl, URL(string: "unknow imageURL"))
        XCTAssertEqual(episodeCellViewModel.audioUrl, URL(string: "unknow audioUrl"))
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy"
        let publishDateString = formatter.string(from: Date())
        XCTAssertEqual(episodeCellViewModel.publishDateString, publishDateString)
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
    //MARK: - Test .calculateFooterHeight()
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
    //MARK: - Test .getEpisodeIndex()
    func testGetEpisodeIndex_EpisodeIsNil(){
        viewModel.episodes = []
        let index = viewModel.getEpisodeIndex(episode: nil)
        XCTAssertNil(index)
    }
    func testGetEpisodeIndex_EpisodeIsUnexist(){
        viewModel.episodes = []
        let targetEpisode = EpisodeCellViewModel(title: "Test title",author: "Test author")
        let index = viewModel.getEpisodeIndex(episode: targetEpisode)
        XCTAssertNil(index)
    }
    func testGetEpisodeIndex_MockEpisode(){
        //取得存在的Episode的index
        viewModel.episodes.append(EpisodeCellViewModel(title: "Ep1", author: "Tony"))
        viewModel.episodes.append(EpisodeCellViewModel(title: "Ep2", author: "Tony"))
        viewModel.episodes.append(EpisodeCellViewModel(title: "Ep3", author: "Tony"))
        
        let targetEpisode = EpisodeCellViewModel(title: "Ep2",author: "Tony")
        let index = viewModel.getEpisodeIndex(episode: targetEpisode)
        XCTAssertEqual(index, 1)
    }
    //MARK: - Test .isPodcastFavorited()
    func testIsPodcastFavorited_EmptyFavorites(){
        let favorites = [FavoritedPodcast]()
        let podcast = Podcast(trackName: "Fuck", artistName: "TonyLee", artworkUrl600: "", trackCount: 99, feedUrl: "")
        let isPodcastFavorited = viewModel.isPodcastFavorited(favorites: favorites, podcast: podcast)
        XCTAssertFalse(isPodcastFavorited)
    }
    func testIsPodcastFavorited_PodcastNotFavorited(){
        let podcast = Podcast(trackName: "Damn it", artistName: "BrianVoong", artworkUrl600: "", trackCount: 99, feedUrl: "")
        let favoritedPodcast = FavoritedPodcast(podcast: podcast)
        let favorites = [favoritedPodcast]
        let targetPodcast = Podcast(trackName: "Fuck", artistName: "TonyLee", artworkUrl600: "", trackCount: 99, feedUrl: "")
        let isPodcastFavorited = viewModel.isPodcastFavorited(favorites: favorites, podcast: targetPodcast)
        XCTAssertFalse(isPodcastFavorited)
    }
    func testIsPodcastFavorited_PodcastWasFavorited(){
        let podcast = Podcast(trackName: "Fuck", artistName: "TonyLee", artworkUrl600: "", trackCount: 99, feedUrl: "")
        let favoritedPodcast = FavoritedPodcast(podcast: podcast)
        let favorites = [favoritedPodcast]
        let targetPodcast = Podcast(trackName: "Fuck", artistName: "TonyLee", artworkUrl600: "", trackCount: 99, feedUrl: "")
        let isPodcastFavorited = viewModel.isPodcastFavorited(favorites: favorites, podcast: targetPodcast)
        XCTAssertTrue(isPodcastFavorited)
    }
    //MARK: - Test .isEpisodeDownloaded()
    func testIsEpisodeDownloaded_EmptyDownloads(){
        let downloads = [DownloadEpisodeCellViewModel]()
        let episode = EpisodeCellViewModel(title: "Test", author: "TonyLee")
        let isEpisodeDownloaded = viewModel.isEpisodeDownloaded(downloads: downloads, episode: episode)
        XCTAssertFalse(isEpisodeDownloaded, "err")
    }
    func testIsEpisodeDownloaded_EpisodeNotDownloaded(){
        let episode = EpisodeCellViewModel(title: "Test", author: "BrianVoong")
        let downloadedEpisode = DownloadEpisodeCellViewModel(episode: episode)
        let downloads = [downloadedEpisode]
        let targeteEpisode = EpisodeCellViewModel(title: "Test", author: "TonyLee")
        let isEpisodeDownloaded = viewModel.isEpisodeDownloaded(downloads: downloads, episode: targeteEpisode)
        XCTAssertFalse(isEpisodeDownloaded, "err")
    }
    func testIsEpisodeDownloaded_EpisodeWasDownloaded(){
        let episode = EpisodeCellViewModel(title: "Test", author: "TonyLee")
        let downloadedEpisode = DownloadEpisodeCellViewModel(episode: episode)
        let downloads = [downloadedEpisode]
        let targeteEpisode = EpisodeCellViewModel(title: "Test", author: "TonyLee")
        let isEpisodeDownloaded = viewModel.isEpisodeDownloaded(downloads: downloads, episode: targeteEpisode)
        XCTAssertTrue(isEpisodeDownloaded, "err")
    }
    //MARK: - Test .saveDownloadEpisodeInUserDefaults()
    func testSaveDownloadEpisodeInUserDefaults(){
        let vms = [DownloadEpisodeCellViewModel(episode: EpisodeCellViewModel(title: "title", author: "tlee")),
                   DownloadEpisodeCellViewModel(episode: EpisodeCellViewModel(title: "title", author: "tlee")),
                   DownloadEpisodeCellViewModel(episode: EpisodeCellViewModel(title: "title", author: "tlee"))]
        MockUserDefaults.standard.saveDownloadEpisode(with: vms)
        let fetchedVMS = MockUserDefaults.standard.fetchDownloadedEpisodes()
        XCTAssertEqual(fetchedVMS.count, 3)
    }
    //MARK: - Test .favoritePodcast()
    func testFavoritePodcast(){
        let podcasts = [Podcast(trackName: "test", artistName: "test", artworkUrl600: "test", trackCount: 99, feedUrl: "test"),
                        Podcast(trackName: "test", artistName: "test", artworkUrl600: "test", trackCount: 99, feedUrl: "test"),
                        Podcast(trackName: "test", artistName: "test", artworkUrl600: "test", trackCount: 99, feedUrl: "test")]
        MockUserDefaults.standard.saveFavoritePodcast(with: podcasts)
        let favoritedPodcast = MockUserDefaults.standard.fetchFavoritePodcasts()
        XCTAssertEqual(favoritedPodcast.count, 3)
    }
    //MARK: - Test .parseXMLFromURL()
    func testParseXMLFromURL_CompleteUrlString(){
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Try to parse XML from url")

        let urlString = "https://feeds.soundcloud.com/users/soundcloud:users:114798578/sounds.rss"
        var episodesResult = [EpisodeCellViewModel]()
        let parser = MockFeedParser(URL: URL(string: urlString)!)
        let publisher = viewModel.parseXMLFromURL(parser: parser)
        publisher
            .sink { (episodes) in
                episodesResult = episodes
                expectation.fulfill()// Fulfill the expectation to indicate that the background task has finished
            }
            .store(in: &subscribers)

        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
        //expression參數 > 測試條件
        //message參數 > 測試失敗的描述
        XCTAssertFalse(episodesResult.isEmpty, "URL is valid, so episodes should not be empty")
        XCTAssert(episodesResult.count == 3)
    }
    func testParseXMLFromURL_EmptyUrlString(){
        viewModel.podcast = Podcast(trackName: "test", artistName: "test", artworkUrl600: "test", trackCount: 0, feedUrl: nil)
        XCTAssertTrue(viewModel.episodes.isEmpty)
        XCTAssertFalse(viewModel.isSearching)
    }
    func testNumberOfEpisodes(){
        viewModel.episodes.append(EpisodeCellViewModel(title: "Ep1", author: "Tony"))
        viewModel.episodes.append(EpisodeCellViewModel(title: "Ep2", author: "Tony"))
        viewModel.episodes.append(EpisodeCellViewModel(title: "Ep3", author: "Tony"))
        let numberOfEpisodes = viewModel.numberOfEpisodes()
        XCTAssertEqual(numberOfEpisodes, 3)
    }
    func testGetEpisodeAtIndex(){
        viewModel.episodes.append(EpisodeCellViewModel(title: "Ep1", author: "Tony"))
        viewModel.episodes.append(EpisodeCellViewModel(title: "Ep2", author: "Tony"))
        viewModel.episodes.append(EpisodeCellViewModel(title: "Ep3", author: "Tony"))
        let episode = viewModel.getEpisode(at: 0)
        XCTAssertEqual(episode.title, "Ep1")
    }
}
//不要讓測試資料污染了UserDefaults
//我們創建一個虛擬環境(MockUserDefaults) + 與現實環境(UserDefaults)相同的Method
//保證一切操作只在虛擬環境,而且驗證的到現實環境的邏輯
class MockUserDefaults {
    static let standard = MockUserDefaults()
    static let mockDownloadKey = "mockDownloadKey"
    static let mockFavoriteKey = "mockFavoriteKey"
    private var dict = [String:Any?]()
    private init(){

    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        dict[defaultName] = value
    }
    func data(forKey defaultName: String) -> Data? {
        if let data = dict[defaultName] as? Data {
            return data
        }
        return nil
    }
    func saveDownloadEpisode(with episodes: [DownloadEpisodeCellViewModel]){
        do {
            let data = try JSONEncoder().encode(episodes)
            set(data, forKey: MockUserDefaults.mockDownloadKey)
        } catch {
            print("Error - Encode object to data failed:\(error)")
        }
    }
    func fetchDownloadedEpisodes()  -> [DownloadEpisodeCellViewModel] {
        guard let downloadedEpisodesData = data(forKey: MockUserDefaults.mockDownloadKey) else {
            print("Info - UserDefaults does not have downloadList")
            return []
        }
        do {
            let downloadedEpisodes = try JSONDecoder().decode([DownloadEpisodeCellViewModel].self, from: downloadedEpisodesData)
            return downloadedEpisodes
        } catch {
            print("Error - Unarchive data to object failed:\(error)")
            return []
        }
    }
    
    func saveFavoritePodcast(with favoriteList: [Podcast]){
        do {
            let data = try JSONEncoder().encode(favoriteList)
            set(data, forKey: MockUserDefaults.mockFavoriteKey)
        } catch {
            print("Error - Encode object to data failed:\(error)")
        }
    }
    func fetchFavoritePodcasts() -> [Podcast] {
        guard let favoriteListData = data(forKey: MockUserDefaults.mockFavoriteKey) else {
            return []
        }
        do {
            //Transform data to object
            let favoritePodcasts = try JSONDecoder().decode([Podcast].self, from: favoriteListData)
            return favoritePodcasts
        } catch {
            print("Error - Unarchive data to object failed:\(error)")
            return []
        }
    }
}
