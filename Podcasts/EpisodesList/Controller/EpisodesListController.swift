//
//  EpisodesController.swift
//  Podcasts
//
//  Created by t19960804 on 4/3/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesListController: UITableViewController {
    var podcast: Podcast! {
        didSet {
            setupViewModel()
            navigationItem.title = podcast.trackName
            viewModel.parseXMLFromURL(with: podcast.feedUrl ?? "")
        }
    }
    let searchingView = SearchingView()
    let viewModel = EpisodesListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupTableView()
        setupConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerStateUpdate(notification:)), name: .playerStateUpdate, object: nil)
    }
    func setupViewModel(){
        viewModel.isSearchingObserver = { [weak self] isSearching in
            DispatchQueue.main.async {
                self?.searchingView.isHidden = !isSearching
            }
        }
        viewModel.reloadControllerObserver = {
            DispatchQueue.main.async { [self] in //Swift5.3改動 > 顯性的表明capture後,不用在block中隱性的加上self.xxx表明capture
                checkIfEpisodeIsPlaying()
                tableView.reloadData()
            }
        }
    }
    fileprivate func setupTableView(){
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.cellID)
        tableView.eliminateExtraSeparators()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfPodcastDidFavorited()
        //Reload data to check if we need hide downloaded image view
        tableView.reloadData()
    }
    @objc fileprivate func handlePlayerStateUpdate(notification: Notification){
        guard let tabbarController = UIApplication.mainTabBarController else { return }
        let info = notification.userInfo
        if let currentEpisode = info?[Notification.episodeKey] as? EpisodeCellViewModel {
            if let index = viewModel.getEpisodeIndex(episode: currentEpisode) {
                viewModel.episodes[index].isPlaying = tabbarController.episodePlayerView.podcastPlayer.isPlayingItem
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
        if let previousEpisode = info?[Notification.previousEpisodeKey] as? EpisodeCellViewModel {
            if let index = viewModel.getEpisodeIndex(episode: previousEpisode) {
                viewModel.episodes[index].isPlaying = false
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    fileprivate func checkIfPodcastDidFavorited(){
        let favoriteBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleFavorite))
        let podcastDidFavorited = viewModel.isPodcastFavorited(podcast: self.podcast)
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
        viewModel.favoritePodcast(podcast: self.podcast)
        let favoritesController = UIApplication.mainTabBarController?.favoritesController
        favoritesController?.tabBarItem.badgeValue = "New"
        navigationItem.rightBarButtonItem = nil
    }
    fileprivate func checkIfEpisodeIsPlaying(){
        guard let tabbarController = UIApplication.mainTabBarController else { return }
        let currentEpisodePlaying = tabbarController.episodePlayerView.viewModel.currentEpisode
        if let index = viewModel.getEpisodeIndex(episode: currentEpisodePlaying) {
            viewModel.episodes[index].isPlaying = tabbarController.episodePlayerView.podcastPlayer.isPlayingItem
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.episodes.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.cellID, for: indexPath) as! EpisodeCell
        let episode = viewModel.episodes[indexPath.row]
        cell.episodeViewModel = episode
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = viewModel.episodes[indexPath.row]
        let tabBarController = UIApplication.mainTabBarController
        tabBarController?.maximizePodcastPlayerView(episodeViewModel: episode, episodesList: viewModel.episodes)
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let episodeWasDownloaded = viewModel.isEpisodeDownloaded(index: indexPath.row)
        if episodeWasDownloaded {
            return nil
        }
        
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
            self.viewModel.downloadEpisode(index: indexPath.row)
            //Reload cell to show downloadedImageView
            self.tableView.reloadRows(at: [indexPath], with: .none)
            //Update Badge
            let downloadController = UIApplication.mainTabBarController?.downloadController
            downloadController?.tabBarItem.badgeValue = "New"
        }
        return [downloadAction]
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel(text: "No Episodes!", font: .boldSystemFont(ofSize: 20), textColor: .purple, textAlignment: .center, numberOfLines: 0)
        return label
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        viewModel.calculateFooterHeight()
        return viewModel.footerHeight
    }
}
