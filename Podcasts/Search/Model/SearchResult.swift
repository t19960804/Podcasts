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
//只要服從Codable protocol,就可以省略NSCoding / NSObject的繼承,並讓data decode to object,或object encode to data
//https://medium.com/@wenchenx/swift-4-codable-%E8%AE%93%E5%BA%8F%E5%88%97%E5%8C%96%E8%AE%8A%E5%BE%97%E6%9B%B4%E7%B0%A1%E5%96%AE-73e55042f077
struct Podcast: Codable {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
