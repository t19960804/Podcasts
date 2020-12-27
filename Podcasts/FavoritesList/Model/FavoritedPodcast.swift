//
//  FavoritedPodcast.swift
//  Podcasts
//
//  Created by t19960804 on 12/27/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation

protocol FavoritedPodcastProtocol {
    var favoriteDate: Date { get set }
}

struct FavoritedPodcast: Codable, PodcastProtocol, FavoritedPodcastProtocol {
    var favoriteDate: Date
    
    var trackName: String?
    
    var artistName: String?
    
    var artworkUrl600: String?
    
    var trackCount: Int?
    
    var feedUrl: String?
    
    init(podcast: Podcast, favoriteDate: Date) {
        self.favoriteDate = favoriteDate
        self.trackName = podcast.trackName
        self.artistName = podcast.artistName
        self.artworkUrl600 = podcast.artworkUrl600
        self.trackCount = podcast.trackCount
        self.feedUrl = podcast.feedUrl
    }
    
}
