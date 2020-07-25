//
//  EpisodesController.swift
//  Podcasts
//
//  Created by t19960804 on 4/3/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    var podcast: Podcast! {
        didSet {
            navigationItem.title = podcast.trackName
            guard let url = podcast.feedUrl else {
                print("Error - feedUrl is nil")
                return
            }
            parseXMLFromURL(with: url)
        }
    }
    let cellID = "EpisodeCell"
    var episodes = [Episode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: cellID)
        tableView.eliminateExtraSeparators()
    }
    fileprivate func parseXMLFromURL(with url: String){
        guard let feedURL = URL(string: url) else { return }
        //不要將Network相關的code放在Controller
        NetworkService.sharedInstance.fetchEpisodes(url: feedURL) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activityIndicatorView.isHidden = !episodes.isEmpty
        return episodes.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = episodes[indexPath.row]
        let tabBarController = UIApplication.mainTabBarController
        tabBarController?.maximizePodcastPlayerView(episode: episode)
    }
    let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        activityIndicatorView.color = .purple
        return activityIndicatorView
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 200
    }
}
