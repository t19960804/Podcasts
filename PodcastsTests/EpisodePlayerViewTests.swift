//
//  EpisodePlayerViewTests.swift
//  PodcastsTests
//
//  Created by t19960804 on 1/3/21.
//  Copyright © 2021 t19960804. All rights reserved.
//

import XCTest
import AVKit

@testable import Podcasts

class EpisodePlayerViewTests: XCTestCase {

    var viewModel: EpisodePlayerViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = EpisodePlayerViewModel()
    }
    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }
    func testPlayNextEpisode(){
        let ep1 = EpisodeCellViewModel(title: "ep1", author: "Tony")
        let ep2 = EpisodeCellViewModel(title: "ep2", author: "Tony")
        let ep3 = EpisodeCellViewModel(title: "ep3", author: "Tony")
        viewModel.episodesList = [ep1,ep2,ep3]
        let _ = viewModel.playNextEpisode(currentEpisode: ep2)
        let curEp = viewModel.currentEpisode
        XCTAssertEqual(curEp?.title, "ep3")
    }
    func testPlayPreviousEpisode(){
        let ep1 = EpisodeCellViewModel(title: "ep1", author: "Tony")
        let ep2 = EpisodeCellViewModel(title: "ep2", author: "Tony")
        let ep3 = EpisodeCellViewModel(title: "ep3", author: "Tony")
        viewModel.episodesList = [ep1,ep2,ep3]
        let _ = viewModel.playPreviousEpisode(currentEpisode: ep2)
        let curEp = viewModel.currentEpisode
        XCTAssertEqual(curEp?.title, "ep1")
    }
    func testUpdateTimeSliderValue(){
        let curTime = CMTime(value: 5, timescale: 1000)
        let duration = CMTime(value: 10, timescale: 1000)
        viewModel.updateTimeSliderValue(currentTime: curTime, duration: duration)
        XCTAssertEqual(viewModel.sliderValue, 0.5)
    }
    func testCalculateSeekTime_TimeSilderDragged(){
        let duration = CMTime(value: 10, timescale: 1000)
        viewModel.calculateSeekTime_TimeSilderDragged(ratio: 0.5, duration: duration)
        let targetTime = CMTime(value: 5, timescale: 1000)
        XCTAssertEqual(viewModel.seekTime, targetTime)
    }
    func testCalculateSeekTime_RewindAndFastforward(){
        let curTime = CMTime(value: 30, timescale: 1)
        //倒轉15秒
        viewModel.calculateSeekTime_RewindAndFastforward(currentTime: curTime, tag: 1)
        let targetTime = CMTime(value: 15, timescale: 1)
        XCTAssertEqual(viewModel.seekTime, targetTime)
        //快轉15秒
        viewModel.calculateSeekTime_RewindAndFastforward(currentTime: curTime, tag: 2)
        let targetTime2 = CMTime(value: 45, timescale: 1)
        XCTAssertEqual(viewModel.seekTime, targetTime2)
    }
}
