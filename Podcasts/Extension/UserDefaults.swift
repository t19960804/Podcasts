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
    //為什麼做save的時候不順便做fetch來減少外部使用的程式碼?
    //若在save裡面做fetch,如果想要對save做測試,發現失敗時會不知道是fetch出問題,還是save本身出問題
    //如果save就存粹的做save,fetch就存粹的做fetch,測試時就不會有上面的問題
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
    
    func saveDownloadEpisode(with episodes: [EpisodeCellViewModel]){
        do {
            let data = try JSONEncoder().encode(episodes)
            set(data, forKey: UserDefaults.downloadKey)
        } catch {
            print("Error - Encode object to data failed:\(error)")
        }
    }
    func fetchDownloadedEpisodes() -> [EpisodeCellViewModel] {
        guard let downloadedEpisodesData = data(forKey: UserDefaults.downloadKey) else {
            print("Info - UserDefaults does not have downloadList")
            return []
        }
        do {
            //Transform data to object
            //".self" represent the actual class type
            let downloadedEpisodes = try JSONDecoder().decode([EpisodeCellViewModel].self, from: downloadedEpisodesData)
            return downloadedEpisodes
        } catch {
            print("Error - Unarchive data to object failed:\(error)")
            return []
        }
    }
}
