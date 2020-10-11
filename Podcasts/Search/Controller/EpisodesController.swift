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
    var episodes = [EpisodeViewModel]()
    let searchingView = SearchingView()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.cellID)
        tableView.eliminateExtraSeparators()
        setupConstraints()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfPodcastDidFavorited()
        //Reload data to check if we need hide downloaded image view
        tableView.reloadData()
    }
    fileprivate func checkIfPodcastDidFavorited(){
        let favoriteBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleFavorite))
        let favoritePodcasts = UserDefaults.standard.fetchFavoritePodcasts()
        let podcastDidFavorited = favoritePodcasts.contains(where: {
             $0.trackName == self.podcast.trackName && $0.artistName == self.podcast.artistName
        })
        navigationItem.rightBarButtonItem = podcastDidFavorited ? nil : favoriteBarButtonItem
    }
    fileprivate func setupConstraints(){
        view.addSubview(searchingView)
        searchingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 20).isActive = true
        searchingView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        searchingView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    @objc fileprivate func handleFavorite(){
        guard let podcast = self.podcast else { return }
        var favoritePodcasts = UserDefaults.standard.fetchFavoritePodcasts()
        favoritePodcasts.append(podcast)
        UserDefaults.standard.saveFavoritePodcast(with: favoritePodcasts)
        let favoritesController = UIApplication.mainTabBarController?.favoritesController
        favoritesController?.tabBarItem.badgeValue = "New"
        navigationItem.rightBarButtonItem = nil
    }
    fileprivate func parseXMLFromURL(with url: String){
        guard let feedURL = URL(string: url) else { return }
        searchingView.isHidden = false
        NetworkService.sharedInstance.fetchEpisodes(url: feedURL) { (result) in
            switch result {
            case .failure(let error):
                print("Error - Parse XML failed:\(error)")
                self.episodes = []
            case .success(let episodes):
                self.episodes = episodes.map({
                    return EpisodeViewModel(episode: $0)
                })
            }
            
            DispatchQueue.main.async {
                self.searchingView.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.cellID, for: indexPath) as! EpisodeCell
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
        tabBarController?.maximizePodcastPlayerView(episodeViewModel: episode, episodesList: episodes)
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var episode = episodes[indexPath.row]
        
        let downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
        let episodeWasDownloaded = downloadedEpisodes.contains(where: {
            $0.title == episode.title && $0.author == episode.author
        })
        if episodeWasDownloaded {
            return nil
        }
        
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
            //Save episode
            episode.isWaitingForDownload = true
            var downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
            downloadedEpisodes.append(episode)
            UserDefaults.standard.saveDownloadEpisode(with: downloadedEpisodes)
            //Reload cell to show downloadedImageView
            self.tableView.reloadRows(at: [indexPath], with: .none)
            //Update Badge
            let downloadController = UIApplication.mainTabBarController?.downloadController
            downloadController?.tabBarItem.badgeValue = "New"
            //Download
            NetworkService.sharedInstance.downloadEpisode(with: episode)
        }
        return [downloadAction]
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel(text: "No Episodes!", font: .boldSystemFont(ofSize: 20), textColor: .purple, textAlignment: .center, numberOfLines: 0)
        return label
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let isSearching = searchingView.isHidden == false
        if isSearching == false && episodes.isEmpty { //Searching完且沒有任何結果
            return 200
        }
        return 0
    }
}
