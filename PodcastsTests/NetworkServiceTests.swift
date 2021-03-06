//
//  NetworkServiceTests.swift
//  PodcastsTests
//
//  Created by t19960804 on 1/3/21.
//  Copyright © 2021 t19960804. All rights reserved.
//

import XCTest
import Combine
import FeedKit

@testable import Podcasts

class NetworkServiceTests: XCTestCase {
    var subscribers: Set<AnyCancellable>!
    let mockURLSession = MockURLSession()
    
    override func setUp() {
        super.setUp()
        subscribers = Set<AnyCancellable>()
        NetworkService.sharedInstance.replaceSession(with: mockURLSession)
    }
    override func tearDown() {
        super.tearDown()
        subscribers.removeAll()
    }
    //MARK: - FetchPodcasts
    func testFetchPodcasts_CompleteSearchText(){
        let expectation = XCTestExpectation(description: "Try to parse XML from url")

        let searchText = "Voong"
        var error: Error?
        var podcastsResult: [Podcast]?
        
        let publisher = NetworkService.sharedInstance.fetchPodcasts(searchText: searchText)
        publisher
            .sink { (completion) in
                switch completion {
                case .failure(let err):
                    error = err
                case .finished:
                    break
                }
                expectation.fulfill()
            } receiveValue: { (searchResult) in
                podcastsResult = searchResult.results
            }
            .store(in: &subscribers)

        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error, "Fetch podcast failed:\(error!)")
        XCTAssertNotNil(podcastsResult, "Fetch podcast success, but podcastsResult should not be nil")
    }
    func testFetchPodcasts_EmptySearchText(){
        let expectation = XCTestExpectation(description: "Try to parse XML from url")

        let searchText = ""
        var error: Error?
        var podcastsResult: [Podcast]?
        
        let publisher = NetworkService.sharedInstance.fetchPodcasts(searchText: searchText)
        publisher
            .sink { (completion) in
                switch completion {
                case .failure(let err):
                    error = err
                case .finished:
                    break
                }
                expectation.fulfill()
            } receiveValue: { (searchResult) in
                podcastsResult = searchResult.results
            }
            .store(in: &subscribers)

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
        let parser = MockFeedParser(URL: URL(string: urlString)!)
        let publisher = NetworkService.sharedInstance.fetchEpisodes(parser: parser)
        publisher
            .sink { (completion) in
                switch completion {
                case .failure(let err):
                    error = err
                case .finished:
                    break
                }
                expectation.fulfill()
            } receiveValue: { (episodes) in
                episodesResult = episodes
            }
            .store(in: &subscribers)

        wait(for: [expectation], timeout: 10.0)
        XCTAssertNil(error, "Fetch episodes failed:\(error!)")
        XCTAssertNotNil(episodesResult, "Fetch success, but episodesResult should not be nil")
        XCTAssert(episodesResult?.count == 3)
    }
}

struct MockURLSession: URLSessionProtocol {
    func dataTaskPublisher(for url: URL) -> AnyPublisher<APIResponse, APIError> {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        let path = Bundle.main.path(forResource: "PodcastData", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        let data = try! Data(contentsOf: url)
        return Result.Publisher((data: data, response: response))
            .eraseToAnyPublisher()
    }
}
struct MockFeedParser: RSSFeedParseProtocol {
    private var url: URL?
    public init(URL: URL) {
        self.url = URL
    }
    func parse(result: @escaping (Result<Feed, ParserError>) -> Void) {
        let rssFeed = RSSFeed()
        let feed = Feed.rss(rssFeed)
        let item1 = RSSFeedItem()
        item1.author = "Brian Voong"
        item1.title = "My Experiences in Computer Science Vs Real World"
        let item2 = RSSFeedItem()
        item2.author = "Brian Voong"
        item2.title = "How and When I Got My Start in Programming"
        let item3 = RSSFeedItem()
        item3.author = "Brian Voong"
        item3.title = "Storyboard vs Code SpeedRun"
        feed.rssFeed?.items = [item1,item2,item3]
        result(Result.success(feed))
    }
}
