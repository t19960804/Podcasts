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
    let description: String
    var imageURL: String?
    var author: String?
    var audioURL: String?
    
    init(item: RSSFeedItem) {
        self.title = item.title ?? ""
        self.pubDate = item.pubDate ?? Date()
        self.description = item.iTunes?.iTunesSubtitle ?? item.description ?? ""
        self.imageURL = item.iTunes?.iTunesImage?.attributes?.href
        self.author = item.iTunes?.iTunesAuthor
        self.audioURL = item.enclosure?.attributes?.url
    }
}
