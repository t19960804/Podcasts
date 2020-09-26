//
//  UserDefaults.swift
//  Podcasts
//
//  Created by t19960804 on 9/12/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation

extension UserDefaults {
    static let favoriteKey = "favoriteKey"
    static let downloadKey = "downloadKey"
    
    func saveFavoritePodcast(with favoriteList: [Podcast]){
        do {
            //Transform object to data
            let data = try JSONEncoder().encode(favoriteList)
            //實際將data透過UserDefaults寫入記憶體需要一點時間,如果太快就把App關掉,會導致改動無效
            //使用.synchronize()也無效
            //https://stackoverflow.com/questions/40808072/when-and-why-should-you-use-nsuserdefaultss-synchronize-method/40809748#40809748
            //https://stackoverflow.com/questions/51904374/userdefaults-sometimes-not-retaining-saved-values-when-restarting-app-swift-4
            set(data, forKey: UserDefaults.favoriteKey)
        } catch {
            print("Error - Encode object to data failed:\(error)")
        }
    }
    func fetchFavoritePodcasts() -> [Podcast] {
        guard let favoriteListData = data(forKey: UserDefaults.favoriteKey) else {
            print("Info - UserDefaults does not have favoriteList")
            return []
        }
        do {
            //Transform data to object
            let favoritePodcasts = try JSONDecoder().decode([Podcast].self, from: favoriteListData)
            return favoritePodcasts
        } catch {
            print("Error - Unarchive data to object failed:\(error)")
            return []
        }
    }
    
    func saveDownloadEpisode(with episodes: [EpisodeViewModel]){
        do {
            let data = try JSONEncoder().encode(episodes)
            set(data, forKey: UserDefaults.downloadKey)
        } catch {
            print("Error - Encode object to data failed:\(error)")
        }
    }
    func fetchDownloadedEpisode() -> [EpisodeViewModel] {
        guard let downloadedEpisodesData = data(forKey: UserDefaults.downloadKey) else {
            print("Info - UserDefaults does not have downloadList")
            return []
        }
        do {
            //Transform data to object
            let downloadedEpisodes = try JSONDecoder().decode([EpisodeViewModel].self, from: downloadedEpisodesData)
            return downloadedEpisodes
        } catch {
            print("Error - Unarchive data to object failed:\(error)")
            return []
        }
    }
}
