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
    var episodeViewModels = [EpisodeViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: cellID)
        tableView.eliminateExtraSeparators()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleFavorite))
    }
    @objc fileprivate func handleFavorite(){
        guard let podcast = self.podcast else { return }
    
        if var favoritePodcasts = UserDefaults.standard.fetchFavoritePodcasts() {
            favoritePodcasts.append(podcast)
            UserDefaults.standard.saveFavoritePodcast(with: favoritePodcasts)
        } else {
            var emptyFavoriteList = [Podcast]()
            emptyFavoriteList.append(podcast)
            UserDefaults.standard.saveFavoritePodcast(with: emptyFavoriteList)
        }
    }
    fileprivate func parseXMLFromURL(with url: String){
        guard let feedURL = URL(string: url) else { return }
        //不要將Network相關的code放在Controller
        NetworkService.sharedInstance.fetchEpisodes(url: feedURL) { (episodes) in
            self.episodeViewModels = episodes.map({
                return EpisodeViewModel(episode: $0)
            })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activityIndicatorView.isHidden = !episodeViewModels.isEmpty
        return episodeViewModels.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! EpisodeCell
        let episodeViewModel = episodeViewModels[indexPath.row]
        cell.episodeViewModel = episodeViewModel
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodeViewModel = episodeViewModels[indexPath.row]
        let tabBarController = UIApplication.mainTabBarController
        tabBarController?.maximizePodcastPlayerView(episodeViewModel: episodeViewModel, episodesList: episodeViewModels)
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
