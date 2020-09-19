//
//  UserDefaults.swift
//  Podcasts
//
//  Created by t19960804 on 9/12/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation

extension UserDefaults {
    static let commonKey = "podcast"
    func saveFavoritePodcast(with favoriteList: [Podcast]){
        do {
            //Transform object to data
            let data = try JSONEncoder().encode(favoriteList)
            UserDefaults.standard.set(data, forKey: UserDefaults.commonKey)
            print("Info - saveFavoritePodcast:\(favoriteList.count)")
        } catch {
            print("Error - Encode object to data failed:\(error)")
        }
    }
    func fetchFavoritePodcasts() -> [Podcast]? {
        guard let favoriteListData = UserDefaults.standard.data(forKey: UserDefaults.commonKey) else {
            print("Info - UserDefaults does not have favoriteList")
            return nil
        }
        do {
            //Transform data to object
            let favoritePodcasts = try JSONDecoder().decode([Podcast].self, from: favoriteListData)
            return favoritePodcasts
        } catch {
            print("Error - Unarchive data to object failed:\(error)")
            return nil
        }
    }
}
