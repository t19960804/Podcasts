//
//  EpisodeListViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 11/28/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation

class EpisodesListViewModel {
    var episodes = [EpisodeCellViewModel]()

    var isSearching = false {
        didSet {
            isSearchingObserver?(isSearching)
        }
    }
    var isSearchingObserver: ((Bool)->Void)?
    
    var footerHeight = 0
    func calculateFooterHeight() {
        if isSearching == false && episodes.isEmpty { //Searching完且沒有任何結果
            footerHeight = 200
        } else {
            footerHeight = 0
        }
    }
    func getEpisodeIndex(episode: EpisodeCellViewModel?) -> Int? {
        guard let index = episodes.firstIndex(where: {
            $0.title == episode?.title && $0.author == episode?.author
        })  else {
            return nil
        }
        return index
    }
    
    func isPodcastFavorited(podcast: Podcast) -> Bool {
        let favoritePodcasts = UserDefaults.standard.fetchFavoritePodcasts()
        let podcastDidFavorited = favoritePodcasts.contains(where: {
             $0.trackName == podcast.trackName && $0.artistName == podcast.artistName
        })
        return podcastDidFavorited
    }
}
