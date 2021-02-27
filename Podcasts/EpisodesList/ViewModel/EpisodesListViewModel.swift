//
//  EpisodeListViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 11/28/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Combine
import UIKit
import FeedKit

class EpisodesListViewModel {
    var episodes = [EpisodeCellViewModel]()
    
    
    @Published var podcast: PodcastProtocol! {
        didSet {
            guard let url = URL(string: podcast.feedUrl ?? "") else {
                print("Error - feedURL is nil")
                self.episodes = []
                isSearching = false
                return
            }
            let parser = FeedParser(URL: url)
            let publisher = parseXMLFromURL(parser: parser)
            fetchEpisodesSubscriber = publisher
                .sink(receiveCompletion: {_ in }) { [unowned self] (episodes) in
                    self.episodes = episodes
                    isSearching = false
                }
        }
    }
    
    @Published var isSearching = false
    private var fetchEpisodesSubscriber: AnyCancellable?
    
    func parseXMLFromURL(parser: RSSFeedParseProtocol) -> AnyPublisher<[EpisodeCellViewModel], Never> {
        isSearching = true
        let publisher = NetworkService.sharedInstance.fetchEpisodes(parser: parser)
        return publisher
            .catch { (error) -> Just<[Episode]> in
                print("Error - Parse XML failed:\(error.localizedDescription)")
                return Just([])
            }
            .map { $0.map { EpisodeCellViewModel(episode: $0) } }
            .eraseToAnyPublisher()
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
    private var downloadEpisodeSubscriber: AnyCancellable?
    
    func downloadEpisode(episode: EpisodeCellViewModel){
        saveDownloadEpisodeInUserDefaults(episode: episode)
        let publisher = NetworkService.sharedInstance.downloadEpisode(with: episode)
        downloadEpisodeSubscriber = publisher
            //.tryMap > 可以throw error的.map
            .tryMap { try Data(contentsOf: $0) }
            .map { (data) -> (Data, URL) in
                let pathOfDocument = FileManager.default.documentsFolderURL
                let url = pathOfDocument.appendingPathComponent("\(episode.title).mp3")
                return (data,url)
            }
            .tryMap { [unowned self] in
                try self.tryToWriteDataToURL(data: $0, url: $1) //寫檔
            }
            .sink { (result) in
                print("Info - Write data result:\(result)")
            } receiveValue: { (url) in //更新Userdefaults
                var downloadEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
                if let index = downloadEpisodes.firstIndex(where: {
                    $0.title == episode.title && $0.author == episode.author
                }) {
                    downloadEpisodes[index].fileUrl = url
                    downloadEpisodes[index].isWaitingForDownload = false
                }
                UserDefaults.standard.saveDownloadEpisode(with: downloadEpisodes)
            }
    }
    fileprivate func tryToWriteDataToURL(data: Data, url: URL) throws -> URL {
        do {
            try data.write(to: url)//https://cdfq152313.github.io/post/2016-10-11/
            return url
        } catch {
            throw error
        }
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
