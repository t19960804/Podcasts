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
        let favoritePodcast = FavoritedPodcast(podcast: podcast, favoriteDate: Date())
        viewModel.favoritePodcasts = [favoritePodcast]
        let height = viewModel.calculateHeightForHeader()
        XCTAssertEqual(height, 0)
    }
}
