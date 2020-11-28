//
//  EpisodePlayerViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 11/28/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation

class EpisodePlayerViewModel {
    var episodesList = [EpisodeCellViewModel]()
    var isSeekingTime = false //防止拖動slider時,slider被update到currentTime

    func getNextEpisode(currentEpisode: EpisodeCellViewModel?) -> EpisodeCellViewModel? {
        guard let currentEpisode = currentEpisode else {
            return nil
        }
        if episodesList.isEmpty {
            print("Error - Can not get next episode because list is empty")
            return nil
        }
        let currentEpisodeIndex = episodesList.firstIndex { $0.title == currentEpisode.title }
        guard let index = currentEpisodeIndex else {
            print("Error - Can not get episode index from list")
            return nil
        }
        
        let needTurnBackToFirstEpisode = index == episodesList.count - 1
        let episode = needTurnBackToFirstEpisode ? episodesList.first : episodesList[index + 1]
        return episode
    }
    
    func getPreviousEpisode(currentEpisode: EpisodeCellViewModel?) -> EpisodeCellViewModel? {
        guard let currentEpisode = currentEpisode else {
            return nil
        }
        if episodesList.isEmpty {
            print("Error - Can not get next episode because list is empty")
            return nil
        }
        let currentEpisodeIndex = episodesList.firstIndex { $0.title == currentEpisode.title }
        guard let index = currentEpisodeIndex else {
            print("Error - Can not get episode index from list")
            return nil
        }
        
        let needTurnBackToLastEpisode = index == 0
        let episode = needTurnBackToLastEpisode ? episodesList.last : episodesList[index - 1]
        return episode
    }
}
