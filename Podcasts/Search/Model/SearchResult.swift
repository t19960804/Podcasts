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
//NSCoding > A protocol that enables an object to be encoded and decoded for archiving and distribution.
//NSSecureCoding > https://www.jianshu.com/p/7e9732f9f1e8
class Podcast: NSObject, Decodable, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        //.archivedData執行時會到這裡
        coder.encode(trackName, forKey: CodableKey.TrackName.rawValue)
        coder.encode(artistName, forKey: CodableKey.ArtistName.rawValue)
        coder.encode(artworkUrl600, forKey: CodableKey.ArtworkUrl600.rawValue)
    }
    
    required init?(coder: NSCoder) {
        //.unarchivedObject執行時會到這裡
        self.trackName = coder.decodeObject(forKey: CodableKey.TrackName.rawValue) as? String
        self.artistName = coder.decodeObject(forKey: CodableKey.ArtistName.rawValue) as? String
        self.artworkUrl600 = coder.decodeObject(forKey: CodableKey.ArtworkUrl600.rawValue) as? String
    }
    
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
    
    enum CodableKey: String {
        case TrackName = "trackName"
        case ArtistName = "artistName"
        case ArtworkUrl600 = "artworkUrl600"
    }
}
