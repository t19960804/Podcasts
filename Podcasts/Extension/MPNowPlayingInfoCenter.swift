//
//  MPNowPlayingInfoCenter.swift
//  Podcasts
//
//  Created by t19960804 on 8/15/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation
import MediaPlayer

extension MPNowPlayingInfoCenter {

    func setElapsedTime(with elpasedTime: CMTime){
        let elpasedTimeWithSeconds = elpasedTime.toSeconds()

        if var nowPlayingInfo = self.nowPlayingInfo {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elpasedTimeWithSeconds
            self.nowPlayingInfo = nowPlayingInfo
        } else {
            var dictionary = [String : Any]()
            dictionary[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elpasedTimeWithSeconds
            self.nowPlayingInfo = dictionary
        }
    }
    func setDuration(with duration: CMTime?){
        guard let duration = duration else { return }
        let durationWithSeconds = duration.toSeconds()
        
        if var nowPlayingInfo = self.nowPlayingInfo {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = durationWithSeconds
            self.nowPlayingInfo = nowPlayingInfo
        } else {
            var dictionary = [String : Any]()
            dictionary[MPMediaItemPropertyPlaybackDuration] = durationWithSeconds
            self.nowPlayingInfo = dictionary
        }
    }
    func setInfo(title: String?, artist: String?, image: UIImage?){
        guard let image = image else { return }
        let artwork = MPMediaItemArtwork(boundsSize: image.size) { (_) -> UIImage in
            return image
        }

        if var nowPlayingInfo = self.nowPlayingInfo {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            self.nowPlayingInfo = nowPlayingInfo
        } else {
            var dictionary = [String : Any]()
            dictionary[MPMediaItemPropertyTitle] = title
            dictionary[MPMediaItemPropertyArtist] = artist
            dictionary[MPMediaItemPropertyArtwork] = artwork
            self.nowPlayingInfo = dictionary
        }
    }
}

