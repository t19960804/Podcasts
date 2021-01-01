//
//  DownloadEpisodeCellViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 12/12/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation

protocol DownloadProtocol {
    var fileUrl: URL? { get set }
    var isWaitingForDownload: Bool { get set }
    var downloadDate: Date { get set }
}
struct DownloadEpisodeCellViewModel: EpisodeProtocol, DownloadProtocol, Codable {
    var downloadDate: Date = Date()
    
    var fileUrl: URL?
    
    var isWaitingForDownload: Bool = true
    
    var title: String
    
    var author: String?
    
    var imageUrl: URL?
    
    var audioUrl: URL?
    
    var publishDateString: String
    
    var duration: String
    
    var isPlaying: Bool
    
    init(episode: EpisodeCellViewModel) {
        self.title = episode.title
        self.author = episode.author
        self.imageUrl = episode.imageUrl
        self.audioUrl = episode.audioUrl
        self.publishDateString = episode.publishDateString
        self.duration = episode.duration
        self.isPlaying = episode.isPlaying
    }
    
    //For unit test
    init(title: String, author: String) {
        self.title = title
        self.author = author
        self.imageUrl = URL(string: "")
        self.audioUrl = URL(string: "")
        self.publishDateString = ""
        self.duration = ""
        self.isPlaying = false
    }
}
