//
//  DownloadListTests.swift
//  PodcastsTests
//
//  Created by t19960804 on 1/1/21.
//  Copyright © 2021 t19960804. All rights reserved.
//

import XCTest
@testable import Podcasts
class DownloadListTests: XCTestCase {

    var viewModel: DownloadListViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = DownloadListViewModel()
    }
    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }
    
    func testGetIndexOfEpisode(){
        let episode1 = DownloadEpisodeCellViewModel(title: "1", author: "test")
        let episode2 = DownloadEpisodeCellViewModel(title: "2", author: "test")
        let episode3 = DownloadEpisodeCellViewModel(title: "3", author: "test")
        
        viewModel.downloadedEpisodes = [episode1,episode2,episode3]
        let index = viewModel.getIndexOfEpisode(episode1)
        XCTAssertEqual(index, 0)
    }

    func testCalculateHeightForFooter(){
        let episode1 = DownloadEpisodeCellViewModel(title: "1", author: "test")
        let episode2 = DownloadEpisodeCellViewModel(title: "2", author: "test")
        let episode3 = DownloadEpisodeCellViewModel(title: "3", author: "test")
        viewModel.downloadedEpisodes = [episode1,episode2,episode3]
        viewModel.calculateHeightForFooter()
        XCTAssertEqual(viewModel.heightForFooter, 0)
    }
    
    func testNumberOfEpisodes(){
        let episode1 = DownloadEpisodeCellViewModel(title: "1", author: "test")
        let episode2 = DownloadEpisodeCellViewModel(title: "2", author: "test")
        let episode3 = DownloadEpisodeCellViewModel(title: "3", author: "test")
        viewModel.downloadedEpisodes = [episode1,episode2,episode3]
        XCTAssertEqual(viewModel.numberOfEpisodes(), 3)
    }
    
    func testGetEpisodeAtIndex(){
        let episode1 = DownloadEpisodeCellViewModel(title: "1", author: "test")
        let episode2 = DownloadEpisodeCellViewModel(title: "2", author: "test")
        let episode3 = DownloadEpisodeCellViewModel(title: "3", author: "test")
        viewModel.downloadedEpisodes = [episode1,episode2,episode3]
        let index = viewModel.getIndexOfEpisode(episode1)
        XCTAssertEqual(index, 0)
    }
}
