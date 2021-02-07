//
//  EpisodePlayerViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 11/28/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Combine
import UIKit
import AVKit

class EpisodePlayerViewModel {
    var isSeekingTime = false //防止拖動slider時,slider被update到currentTime
    
    
    var previousEpisode: EpisodeProtocol?
    
    @Published var currentEpisode: EpisodeProtocol? {
        didSet { //didSet會早於.sink觸發
            previousEpisode = oldValue
            startToPlayEpisode = false
            sliderValue = 0
            seekTime = CMTime(seconds: 0, preferredTimescale: 1000)
            setupAudioSession()//播放時再取得Audio使用權
        }
    }
    
    //MARK: - PlayerStateObserver
    @Published var needToPausePlayer = false

    @Published var startToPlayEpisode = false

    //MARK: - EpisodeObserver
    var episodesList = [EpisodeProtocol]()
    
    func playNextEpisode(currentEpisode: EpisodeProtocol?) -> Bool {
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
        let newEpisode = needTurnBackToFirstEpisode ? episodesList.first : episodesList[index + 1]
        self.currentEpisode = newEpisode
        return true
    }
    
    func playPreviousEpisode(currentEpisode: EpisodeProtocol?) -> Bool {
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
        let newEpisode = needTurnBackToLastEpisode ? episodesList.last : episodesList[index - 1]
        self.currentEpisode = newEpisode
        return true
    }
    //MARK: - SliderObserver
    @Published var sliderValue: Float64 = 0

    func updateTimeSliderValue(currentTime: CMTime, duration: CMTime){
        let currentSeconds = currentTime.toSeconds()
        let totalSeconds = duration.toSeconds()
        let progressPercent = currentSeconds / totalSeconds
        sliderValue = progressPercent
    }
    //MARK: - SeekTimeObserver
    @Published var seekTime = CMTime(seconds: 1, preferredTimescale: 1000)

    func calculateSeekTime_TimeSilderDragged(ratio: Float, duration: CMTime){
        let durationInSeconds = duration.toSeconds()
        //總秒數乘以Slider的值(0 - 1),做為要快 / 倒轉的秒數
        let seekTimeInSeconds = Float64(ratio) * durationInSeconds
        //一秒切成1000份(1份 = 0.001秒),假設我們想要123.45秒,AVKit可以處理0.45秒(450份)
        //若preferredTimescale為1,將無法處理小數點的情況,因為小數點不滿一份(1秒)
        let seekTime = CMTime(seconds: seekTimeInSeconds, preferredTimescale: 1000)
        self.seekTime = seekTime
    }
    
    func calculateSeekTime_RewindAndFastforward(currentTime: CMTime, tag: Int){
        let deltaSeconds: Int64 = tag == 1 ? -15 : 15
        let deltaTime = CMTime(value: deltaSeconds, timescale: 1)
        let seekTime = CMTimeAdd(currentTime, deltaTime)
        self.seekTime = seekTime
    }
    
    @Published var volume: Float = 0.0

    //MARK: - Other
    //若沒有加入此Function,有時背景播放會無效
    func setupAudioSession(){
        do {
            //https://ithelp.ithome.com.tw/articles/10195770?sc=iThelpR
            try AVAudioSession.sharedInstance().setCategory(.playback)
            //向OS請求使用Audio,因為多個App中只能有一個使用Audio,比如一通電話打來,電話就有使用Audio的最高優先,低優先的會被暫停
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionError{
            //https://stackoverflow.com/questions/31352593/how-to-print-details-of-a-catch-all-exception-in-swift
            print("Set up session failed:\(sessionError)")
        }
    }
    
    func handleInteruption(notification: Notification){
        let userInfo = notification.userInfo
        guard let interruptionType = userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else {
            return
        }
        if interruptionType == AVAudioSession.InterruptionType.began.rawValue {
            needToPausePlayer = true
        }
    }
}
