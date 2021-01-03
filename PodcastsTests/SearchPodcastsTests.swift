//
//  SearchPodcastsTests.swift
//  PodcastsTests
//
//  Created by t19960804 on 1/3/21.
//  Copyright © 2021 t19960804. All rights reserved.
//

import XCTest
@testable import Podcasts

class SearchPodcastsTests: XCTestCase {

    var viewModel: SearchPodcastsViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = SearchPodcastsViewModel()
    }
    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }
    
    func testSearchBarInputUpdate(){
        viewModel.searchBarInputUpdate(input: "")
        XCTAssertEqual(viewModel.headerLabelString, "Please enter a search query")
        let input = "Test"
        viewModel.searchBarInputUpdate(input: input)
        XCTAssertEqual(viewModel.headerLabelString, "There is no podcast about: \(input)")
    }
    
    func testCalculateHeightForHeader(){
        viewModel.isSearching = false
        viewModel.podcasts = []
        let height1 = viewModel.calculateHeightForHeader()
        XCTAssertEqual(height1, 250)
        viewModel.isSearching = true
        let height2 = viewModel.calculateHeightForHeader()
        XCTAssertEqual(height2, 0)
    }
}
