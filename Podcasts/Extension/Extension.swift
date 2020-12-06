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
            if episode.imageURL == "unknow imageURL" { //若沒有episode封面,則用Podcast封面
                let imageURLString = self.iTunes?.iTunesImage?.attributes?.href
                episode.imageURL = imageURLString?.turnHTTPToHTTPS() ?? ""
            }
            episodes.append(episode)
        }
        return episodes
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

extension UIImageView {
    convenience init(image: UIImage = UIImage(), cornerRadius: CGFloat = 0, clipsToBounds: Bool = false){
        self.init()
        self.image = image
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = clipsToBounds
    }
    func startAnimating(images: [UIImage], duration: TimeInterval, repeatCount: Int){
        self.animationImages = images
        //The amount of time it takes to go through one cycle of the images.
        self.animationDuration = duration
        //The default value is 0, which specifies to repeat the animation indefinitely
        self.animationRepeatCount = repeatCount
        self.startAnimating()
    }
}

extension MainTabBarController {
    var favoritesController: FavoritesListController? {
        guard let navigationController = viewControllers?[TabBarControllerType.Favorites.rawValue] as? UINavigationController else {
            return nil
        }
        return navigationController.viewControllers.first as? FavoritesListController
    }
    var downloadController: DownloadListController? {
        guard let navigationController = viewControllers?[TabBarControllerType.Downloads.rawValue] as? UINavigationController else {
            return nil
        }
        return navigationController.viewControllers.first as? DownloadListController
    }
}

extension NSNotification.Name {
    static let episodeDownloadDone = NSNotification.Name(rawValue: "episodeDownloadDone")
    static let progressUpdate = NSNotification.Name("progressUpdate")
    static let newPodcastStartPlaying = NSNotification.Name("newPodcastStartPlaying")
    static let playerStateUpdate = NSNotification.Name(rawValue: "playerStateUpdate")
}

extension Notification {
    static let episodeKey = "episode"
    static let progressKey = "progress"
    static let previousEpisodeKey = "previousEpisodeKey"
}
extension URL {
    func getTrueLocation() -> URL? {
        //每一次重新啟動App,資料夾的路徑會有所變動
        //若依照當初下載檔案後所存fileUrl會無法找到檔案
        var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = self.lastPathComponent
        trueLocation?.appendPathComponent(fileName)
        return trueLocation
    }
}
extension UIImage {
    //https://stackoverflow.com/questions/27148994/uiimage-animationimages-tint-color
    func withColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage else { return UIImage() }
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage)
        color.setFill()
        context.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
    static var audioImages: [UIImage] {
        var images = [UIImage]()
        for i in 0...3 {
            images.append(UIImage(named: "audio-\(i)")!.withColor(.white))
        }
        return images
    }
}

extension AVPlayer {
    //若使用static,會讓isPlayingItem屬於AVPlayer類別,這時self指的是AVPlayer類別,可是.timeControlStatus屬性只能用在AVPlayer物件,所以會報錯
    var isPlayingItem: Bool {
        return self.timeControlStatus == .playing
    }
}
