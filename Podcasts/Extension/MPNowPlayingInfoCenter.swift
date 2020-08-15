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
    func setTitle(with title: String?){
        if var nowPlayingInfo = self.nowPlayingInfo {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
            self.nowPlayingInfo = nowPlayingInfo
        } else {
            var dictionary = [String : Any]()
            dictionary[MPMediaItemPropertyTitle] = title
            self.nowPlayingInfo = dictionary
        }
    }
    func setArtist(with artist: String?){
        if var nowPlayingInfo = self.nowPlayingInfo {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
            self.nowPlayingInfo = nowPlayingInfo
        } else {
            var dictionary = [String : Any]()
            dictionary[MPMediaItemPropertyArtist] = artist
            self.nowPlayingInfo = dictionary
        }
    }
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
    func setImage(with image: UIImage?){
        guard let image = image else { return }
        let artwork = MPMediaItemArtwork(boundsSize: image.size) { (_) -> UIImage in
            return image
        }
        
        if var nowPlayingInfo = self.nowPlayingInfo {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            self.nowPlayingInfo = nowPlayingInfo
        } else {
            var dictionary = [String : Any]()
            dictionary[MPMediaItemPropertyArtwork] = artwork
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
}

