//
//  EpisodePlayerViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 11/28/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class EpisodePlayerViewModel {
    var episodesList = [EpisodeCellViewModel]()
    var isSeekingTime = false //防止拖動slider時,slider被update到currentTime
    
    var needToPausePlayer = false {
        didSet {
            let image = needToPausePlayer ? UIImage(named: "play") : UIImage(named: "pause")
            needToPausePlayerObserver?(needToPausePlayer,image ?? UIImage())
        }
    }
    var needToPausePlayerObserver: ((Bool,UIImage)->Void)?
    
    var newEpisode: EpisodeCellViewModel! {
        didSet {
            newEpisodePlayObserver?(newEpisode)
        }
    }
    var newEpisodePlayObserver: ((EpisodeCellViewModel)->Void)?
    
    func playNextEpisode(currentEpisode: EpisodeCellViewModel?) -> Bool {
        guard let currentEpisode = currentEpisode else {
            return false
        }
        if episodesList.isEmpty {
            print("Error - Can not get next episode because list is empty")
            return false
        }
        let currentEpisodeIndex = episodesList.firstIndex { $0.title == currentEpisode.title }
        guard let index = currentEpisodeIndex else {
            print("Error - Can not get episode index from list")
            return false
        }
        
        let needTurnBackToFirstEpisode = index == episodesList.count - 1
        let episode = needTurnBackToFirstEpisode ? episodesList.first : episodesList[index + 1]
        newEpisode = episode
        return true
    }
    
    func playPreviousEpisode(currentEpisode: EpisodeCellViewModel?) -> Bool {
        guard let currentEpisode = currentEpisode else {
            return false
        }
        if episodesList.isEmpty {
            print("Error - Can not get next episode because list is empty")
            return false
        }
        let currentEpisodeIndex = episodesList.firstIndex { $0.title == currentEpisode.title }
        guard let index = currentEpisodeIndex else {
            print("Error - Can not get episode index from list")
            return false
        }
        
        let needTurnBackToLastEpisode = index == 0
        let episode = needTurnBackToLastEpisode ? episodesList.last : episodesList[index - 1]
        newEpisode = episode
        return true
    }
    
    var sliderValue: Float64 = 0 {
        didSet {
            let floatValue = Float(sliderValue)
            sliderValueUpdateObserver?(floatValue)
        }
    }
    
    var sliderValueUpdateObserver: ((Float)->Void)?
    
    func updateTimeSliderValue(currentTime: CMTime, duration: CMTime){
        let currentSeconds = currentTime.toSeconds()
        let totalSeconds = duration.toSeconds()
        let progressPercent = currentSeconds / totalSeconds
        sliderValue = progressPercent
    }
    
    //若沒有加入此Function,有時背景播放會無效
    func setupAudioSession(){
        do {
            //https://ithelp.ithome.com.tw/articles/10195770?sc=iThelpR
            //App - AVAudioSession(中介) - OS
            //使用AVAudioSession來告訴OS我們要在App中要如何使用Audio
            try AVAudioSession.sharedInstance().setCategory(.playback)
            //向OS請求使用Audio,因為多個App中只能有一個使用Audio,比如一通電話打來,電話就有使用Audio的最高優先,低優先的會被暫停
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionError{
            //https://stackoverflow.com/questions/31352593/how-to-print-details-of-a-catch-all-exception-in-swift
            print("Set up session failed:\(sessionError)")
        }
    }
    
    var seekTime = CMTime(seconds: 1, preferredTimescale: 1000){
        didSet {
            let timeString = seekTime.getFormattedString()
            lowerBoundTimeLabelUpdateObserver?(timeString)
        }
    }
    var lowerBoundTimeLabelUpdateObserver: ((String)->Void)?
    
    func calculateSeekTime(ratio: Float, duration: CMTime){
        let durationInSeconds = duration.toSeconds()
        //總秒數乘以Slider的值(0 - 1),做為要快 / 倒轉的秒數
        let seekTimeInSeconds = Float64(ratio) * durationInSeconds
        //一秒切成1000份(1份 = 0.001秒),假設我們想要123.45秒,AVKit可以處理0.45秒(450份)
        //若preferredTimescale為1,將無法處理小數點的情況,因為小數點不滿一份(1秒)
        let seekTime = CMTime(seconds: seekTimeInSeconds, preferredTimescale: 1000)
        self.seekTime = seekTime
    }
}
