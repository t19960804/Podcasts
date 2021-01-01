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
    
    var podcastUpdateObserver: ((PodcastProtocol)->Void)?
    
    var podcast: PodcastProtocol! {
        didSet {
            podcastUpdateObserver?(podcast)
            parseXMLFromURL(with: podcast.feedUrl ?? "") { [self] (result) in
                switch result {
                case .failure(let error):
                    print("Error - Parse XML failed:\(error)")
                    episodes = []
                case .success(let episodes):
                    self.episodes = episodes.map { EpisodeCellViewModel(episode: $0) }
                }
                isSearching = false
            }
        }
    }
    
    var isSearching = false {
        didSet {
            isSearchingObserver?(isSearching)
            reloadControllerObserver?()
        }
    }
    var isSearchingObserver: ((Bool)->Void)?
    var reloadControllerObserver: (()->Void)?
    
    
    func parseXMLFromURL(with url: String, completion: @escaping (Result<[Episode],Error>) -> Void) {
        guard let feedURL = URL(string: url) else {
            print("Error - feedURL is nil")
            return
        }
        isSearching = true
        NetworkService.sharedInstance.fetchEpisodes(url: feedURL, completion: completion)
    }
    
    var footerHeight: CGFloat = 0
    func calculateFooterHeight() {
        if isSearching == false && episodes.isEmpty { //Searching完且沒有任何結果
            footerHeight = 200
        } else {
            footerHeight = 0
        }
    }
    func getEpisodeIndex(episode: EpisodeProtocol?) -> Int? {
        guard let index = episodes.firstIndex(where: {
            $0.title == episode?.title && $0.author == episode?.author
        })  else {
            return nil
        }
        return index
    }
    
    func isPodcastFavorited(favorites: [FavoritedPodcast], podcast: PodcastProtocol) -> Bool {
        let podcastDidFavorited = favorites.contains(where: {
             $0.trackName == podcast.trackName && $0.artistName == podcast.artistName
        })
        return podcastDidFavorited
    }
    
    func isEpisodeDownloaded(downloads: [DownloadEpisodeCellViewModel], episode: EpisodeCellViewModel) -> Bool {
        let episodeWasDownloaded = downloads.contains(where: {
            $0.title == episode.title && $0.author == episode.author
        })
        return episodeWasDownloaded
    }
    
    func downloadEpisode(episode: EpisodeCellViewModel){
        saveDownloadEpisodeInUserDefaults(episode: episode)
        NetworkService.sharedInstance.downloadEpisode(with: episode)
    }
    
    func saveDownloadEpisodeInUserDefaults(episode: EpisodeCellViewModel){
        let downloadEpisode = DownloadEpisodeCellViewModel(episode: episode)
        var downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
        downloadedEpisodes.append(downloadEpisode)
        UserDefaults.standard.saveDownloadEpisode(with: downloadedEpisodes)
    }
    
    func favoritePodcast(podcast: FavoritedPodcast){
        var favoritePodcasts = UserDefaults.standard.fetchFavoritePodcasts()
        favoritePodcasts.append(podcast)
        UserDefaults.standard.saveFavoritePodcast(with: favoritePodcasts)
    }
    
    func numberOfEpisodes() -> Int {
        return episodes.count
    }
    
    func getEpisode(at index: Int) -> EpisodeCellViewModel {
        return episodes[index]
    }
}
