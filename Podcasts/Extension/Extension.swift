//
//  Extension.swift
//  Podcasts
//
//  Created by t19960804 on 4/4/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import FeedKit

extension UITableView {
    func eliminateExtraSeparators(){
        //清除tableView多餘的分隔線(若設定.separatorStyle = .none會導致cell之間的分隔線完全消失)
        //https://stackoverflow.com/questions/1369831/eliminate-extra-separators-below-uitableview
        self.tableFooterView = UIView()
    }
}

extension String {
    func turnHTTPToHTTPS() -> String {
        if self.contains("http") {
            return self.replacingOccurrences(of: "http", with: "https")
        }
        return self
    }
}


extension RSSFeed {
    func getEpisodes() -> [Episode]{
        var episodes = [Episode]()
        
        self.items?.forEach {
            var episode = Episode(item: $0)
            if episode.imageURL == nil { //若沒有episode封面,則用Podcast封面
                let imageURLString = self.iTunes?.iTunesImage?.attributes?.href
                episode.imageURL = imageURLString?.turnHTTPToHTTPS()
            }
            episodes.append(episode)
        }
        return episodes
    }
}
