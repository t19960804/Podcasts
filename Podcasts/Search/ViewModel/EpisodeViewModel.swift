//
//  EpisodeViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 8/1/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation

struct EpisodeViewModel {
    let title: String
    let author: String?
    var imageUrl: URL?
    var audioUrl: URL?
    let publishDateString: String
    let description: String
    
    //Dependency Injection
    init(episode: Episode) {
        self.title = episode.title
        self.author = episode.author
        self.imageUrl = URL(string: episode.imageURL ?? "")
        self.audioUrl = URL(string: episode.audioURL ?? "")
        self.description = episode.description
        
        //Date to Custom String
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy"
        self.publishDateString = formatter.string(from: episode.pubDate)
    }
}
