//
//  Episode.swift
//  Podcasts
//
//  Created by t19960804 on 4/3/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation
import FeedKit

struct Episode {
    let title: String
    let pubDate: Date
    let duration: Int
    var imageURL: String
    let author: String
    let audioURL: String
    
    init(item: RSSFeedItem) {
        self.title = item.title ?? "unknow title"
        self.pubDate = item.pubDate ?? Date()
        self.duration = Int(item.iTunes?.iTunesDuration ?? 999.0)
        self.imageURL = item.iTunes?.iTunesImage?.attributes?.href ?? "unknow imageURL"
        self.author = item.iTunes?.iTunesAuthor ?? "unknow author"
        self.audioURL = item.enclosure?.attributes?.url ?? "unknow audioURL"
    }
}
