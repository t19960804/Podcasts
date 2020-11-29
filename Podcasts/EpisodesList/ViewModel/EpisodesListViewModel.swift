//
//  EpisodeListViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 11/28/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation
import UIKit

class EpisodesListViewModel {
    var episodes = [EpisodeCellViewModel]()

    var isSearching = false {
        didSet {
            isSearchingObserver?(isSearching)
            reloadControllerObserver?()
        }
    }
    var isSearchingObserver: ((Bool)->Void)?
    var reloadControllerObserver: (()->Void)?
    
    
    func parseXMLFromURL(with url: String) {
        guard let feedURL = URL(string: url) else {
            print("Error - feedURL is nil")
            return
        }
        isSearching = true
        NetworkService.sharedInstance.fetchEpisodes(url: feedURL) { (result) in
            switch result {
            case .failure(let error):
                print("Error - Parse XML failed:\(error)")
                self.episodes = []
            case .success(let episodes):
                self.episodes = episodes.map { EpisodeCellViewModel(episode: $0) }
            }
            self.isSearching = false
        }
    }
    
    var footerHeight: CGFloat = 0
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
    
    func isEpisodeDownloaded(index: Int) -> Bool {
        let episode = episodes[index]
        let downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
        let episodeWasDownloaded = downloadedEpisodes.contains(where: {
            $0.title == episode.title && $0.author == episode.author
        })
        return episodeWasDownloaded
    }
    
    func downloadEpisode(index: Int){
        //Save episode
        var episode = episodes[index]
        episode.isWaitingForDownload = true
        var downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
        downloadedEpisodes.append(episode)
        UserDefaults.standard.saveDownloadEpisode(with: downloadedEpisodes)
        //Download
        NetworkService.sharedInstance.downloadEpisode(with: episode)
    }
    
    func favoritePodcast(podcast: Podcast?){
        guard let podcast = podcast else { return }
        var favoritePodcasts = UserDefaults.standard.fetchFavoritePodcasts()
        favoritePodcasts.append(podcast)
        UserDefaults.standard.saveFavoritePodcast(with: favoritePodcasts)
    }
}
