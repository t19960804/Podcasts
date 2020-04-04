//
//  Podcasts.swift
//  Podcasts
//
//  Created by t19960804 on 2/29/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation

struct SearchResult: Decodable {
    let resultCount: Int
    let results: [Podcast]
}
struct Podcast: Decodable {
    var trackName: String?
    let artistName: String
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
