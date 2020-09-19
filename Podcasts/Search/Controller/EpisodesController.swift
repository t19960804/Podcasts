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
    let searchingView = SearchingView()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: cellID)
        tableView.eliminateExtraSeparators()
        
        setupConstraints()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleFavorite))
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
    
        if var favoritePodcasts = UserDefaults.standard.fetchFavoritePodcasts() {
            favoritePodcasts.append(podcast)
            UserDefaults.standard.saveFavoritePodcast(with: favoritePodcasts)
        } else {
            var emptyFavoriteList = [Podcast]()
            emptyFavoriteList.append(podcast)
            UserDefaults.standard.saveFavoritePodcast(with: emptyFavoriteList)
        }
        guard let favoritesController = UIApplication.mainTabBarController?.viewControllers?[TabBarControllerType.Favorites.rawValue] else {
            return
        }
        favoritesController.tabBarItem.badgeValue = "New"
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
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel(text: "No Episodes!", font: .boldSystemFont(ofSize: 20), textColor: .purple, textAlignment: .center, numberOfLines: 0)
        return label
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let isSearching = searchingView.isHidden == false
        if isSearching == false && episodeViewModels.isEmpty {
            return 200
        }
        return 0
    }
}
