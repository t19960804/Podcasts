//
//  Extension.swift
//  Podcasts
//
//  Created by t19960804 on 4/4/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import FeedKit
import AVKit

extension UITableView {
    func eliminateExtraSeparators(){
        //清除tableView多餘的分隔線(若設定.separatorStyle = .none會導致cell之間的分隔線完全消失)
        //https://stackoverflow.com/questions/1369831/eliminate-extra-separators-below-uitableview
        self.tableFooterView = UIView()
    }
}

extension String {
    func turnHTTPToHTTPS() -> String {
        let unsecureString = "http:"
        if self.contains(unsecureString) {
            return self.replacingOccurrences(of: unsecureString, with: "https:")
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

extension CMTime {
    func getFormattedString() -> String {
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let second = totalSeconds % 60
        let minute = totalSeconds / 60
        let hours = minute / 60
        //https://stackoverflow.com/questions/25566581/leading-zeros-for-int-in-swift
        //不夠兩位數就補0, 5 > 05
        let formattedString = String(format: "%02d:%02d:%02d", hours,minute,second)
        return formattedString
    }
}

extension UIStackView {
    //A convenience initializer must call another initializer from the same class.
    convenience init(subViews: [UIView], axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 0){
        self.init(arrangedSubviews: subViews)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
    }
    //https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/swift-%E7%9A%84%E5%8F%83%E6%95%B8%E9%A0%90%E8%A8%AD%E5%80%BC-default-parameter-values-fe08042d2d66
    //http://jason9075.logdown.com/posts/285685-swift-note-initialization-rules-convenience-and-designated-initializer-usage
}

extension UIApplication {
    static var mainTabBarController: MainTabBarController? {
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
