//
//  DownloadListViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 11/22/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation

class DownloadListViewModel {
    var downloadedEpisodes = [EpisodeViewModel]()
    
    func getIndexOfEpisode(_ episode: EpisodeViewModel?) -> Int? {
        guard let index = downloadedEpisodes.firstIndex(where: {
            $0.title == episode?.title && $0.author == episode?.author
        }) else {
            return nil
        }
        return index
    }
    
    var heightForFooter = 0
    func calculateHeightForFooter() {
        heightForFooter = downloadedEpisodes.isEmpty ? 200 : 0
    }
    
    func removeEpisodeFromFileManager(url: URL) {
        do {
           try FileManager.default.removeItem(at: url)
        } catch {
            print("Error - Remove downloaded file failed:\(error)")
        }
    }
    func removeEpisodeFromUserDefaults(episode: EpisodeViewModel?) {
        if let index = getIndexOfEpisode(episode) {
            //先把狀態改為false並存起來,存完再打開
            //不然會把播放中的狀態存進去
            downloadedEpisodes[index].isPlaying = false
            UserDefaults.standard.saveDownloadEpisode(with: downloadedEpisodes)
            downloadedEpisodes[index].isPlaying = true
        } else {
            UserDefaults.standard.saveDownloadEpisode(with: downloadedEpisodes)
        }
    }
}
