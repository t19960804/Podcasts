//
//  Podcasts.swift
//  Podcasts
//
//  Created by t19960804 on 2/29/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation

protocol PodcastProtocol {
    var trackName: String? { get set }
    var artistName: String? { get set }
    var artworkUrl600: String? { get set }
    var trackCount: Int? { get set }
    var feedUrl: String? { get set }
}
struct SearchResult: Decodable {
    let resultCount: Int
    let results: [Podcast]
}
struct Podcast: Codable, PodcastProtocol {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
