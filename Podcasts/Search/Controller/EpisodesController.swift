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
    var episodeViewModels = [EpisodeViewModel]()
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
                self.episodeViewModels = []
            case .success(let episodes):
                self.episodeViewModels = episodes.map({
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
        return episodeViewModels.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.cellID, for: indexPath) as! EpisodeCell
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
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
            var downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisode()
            let episodeViewModel = self.episodeViewModels[indexPath.row]
            downloadedEpisodes.append(episodeViewModel)
            UserDefaults.standard.saveDownloadEpisode(with: downloadedEpisodes)
            
            let downloadController = UIApplication.mainTabBarController?.downloadController
            downloadController?.tabBarItem.badgeValue = "New"
            //Download real episode file from internet
            NetworkService.sharedInstance.downloadEpisode(with: episodeViewModel)
        }
        return [downloadAction]
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel(text: "No Episodes!", font: .boldSystemFont(ofSize: 20), textColor: .purple, textAlignment: .center, numberOfLines: 0)
        return label
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let isSearching = searchingView.isHidden == false
        if isSearching == false && episodeViewModels.isEmpty { //Searching完且沒有任何結果
            return 200
        }
        return 0
    }
}
