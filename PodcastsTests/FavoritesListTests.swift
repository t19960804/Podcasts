//
//  FavoritesList.swift
//  PodcastsTests
//
//  Created by t19960804 on 12/26/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import XCTest
@testable import Podcasts

class FavoritesListTests: XCTestCase {

    var viewModel: FavoritesListViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = FavoritesListViewModel()
    }
    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }
    func testCalculateHeightForHeader_EmptyPodcast() {
        viewModel.favoritePodcasts = []
        let height = viewModel.calculateHeightForHeader()
        XCTAssertEqual(height, 250)
    }
    func testCalculateHeightForHeader_HasPodcast() {
        let podcast = Podcast(trackName: "", artistName: "", artworkUrl600: "", trackCount: 99, feedUrl: "")
        let favoritePodcast = FavoritedPodcast(podcast: podcast)
        viewModel.favoritePodcasts = [favoritePodcast]
        let height = viewModel.calculateHeightForHeader()
        XCTAssertEqual(height, 0)
    }
    func testGetPodcast(){
        let podcast1 = FavoritedPodcast(podcast: Podcast(trackName: "1", artistName: "", artworkUrl600: "", trackCount: 99, feedUrl: ""))
        let podcast2 = FavoritedPodcast(podcast: Podcast(trackName: "2", artistName: "", artworkUrl600: "", trackCount: 99, feedUrl: ""))
        let podcast3 = FavoritedPodcast(podcast: Podcast(trackName: "3", artistName: "", artworkUrl600: "", trackCount: 99, feedUrl: ""))
        
        viewModel.favoritePodcasts = [podcast1,podcast2,podcast3]
        let podcast = viewModel.getPodcast(at: 0)
        XCTAssertEqual(podcast.trackName, "1")
    }
    func testNumberOfPodcast(){
        let podcast1 = FavoritedPodcast(podcast: Podcast(trackName: "1", artistName: "", artworkUrl600: "", trackCount: 99, feedUrl: ""))
        let podcast2 = FavoritedPodcast(podcast: Podcast(trackName: "2", artistName: "", artworkUrl600: "", trackCount: 99, feedUrl: ""))
        let podcast3 = FavoritedPodcast(podcast: Podcast(trackName: "3", artistName: "", artworkUrl600: "", trackCount: 99, feedUrl: ""))
        
        viewModel.favoritePodcasts = [podcast1,podcast2,podcast3]
        let number = viewModel.numberOfPodcast()
        XCTAssertEqual(number, 3)
    }
}
