//
//  EpisodeViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 8/1/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation

struct EpisodeViewModel: Codable {
    let title: String
    let author: String?
    var imageUrl: URL?
    var audioUrl: URL?
    let publishDateString: String
    let duration: String
    var fileUrl: URL?
    var isWaitingForDownload = false
    
    //Dependency Injection
    //在單元測試中,我們可以在外部創建Model,並隨意修改Model的屬性,來測試ViewModel的邏輯
    init(episode: Episode) {
        self.title = episode.title
        self.author = episode.author
        self.imageUrl = URL(string: episode.imageURL)
        self.audioUrl = URL(string: episode.audioURL)
        
        //Date to Custom String
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy"
        self.publishDateString = formatter.string(from: episode.pubDate)
        
        let second = episode.duration % 60
        let minute = episode.duration / 60
        let formattedString = String(format: "%02d:%02d",minute,second)
        self.duration = formattedString
    }
}

//ViewModel好處:
//1.當很多個View需要來自Model的資料時
//  我們需要在每個View對資料做處理(Optional binding / 邏輯判斷)
//  現在將這些處理資料的邏輯全部移到ViewModel
//  這樣一來View只要使用來自ViewModel的資料即可
//  Model -> ViewModel -> View

//2.MVC的架構下,資料呈現的邏輯都放在View中
//  所以單元測試中測試那些邏輯時需要連同View也一起創建,造成測試困難
//  MVVM中,呈現的邏輯都放在ViewModel中,所以不再需要另外創建View物件,可以專注在測試邏輯
//  https://stackoverflow.com/questions/56686819/why-is-unit-testing-harder-in-mvc-than-in-mvp-and-mvvm
