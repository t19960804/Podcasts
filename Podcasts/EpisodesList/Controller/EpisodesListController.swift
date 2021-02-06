//
//  EpisodesController.swift
//  Podcasts
//
//  Created by t19960804 on 4/3/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import FeedKit
import Combine

class EpisodesListController: UITableViewController {
    
    private let searchingView = SearchingView()
    private let viewModel = EpisodesListViewModel()
    private var isSearchingSubscriber: AnyCancellable?
    
    //MARK: - Init method
    init() {
        super.init(style: .plain)
        setupViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupTableView()
        setupConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerStateUpdate(notification:)), name: .playerStateUpdate, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfPodcastDidFavorited()
        //Reload data to check if we need hide downloaded image view
        tableView.reloadData()
        setupIsSearchingSubscriber()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isSearchingSubscriber?.cancel()
    }
    //MARK: - Constraints
    fileprivate func setupConstraints(){
        view.addSubview(searchingView)
        searchingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 20).isActive = true
        searchingView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        searchingView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    //MARK: - Other Methods
    func updatePodcast(with podcast: PodcastProtocol){
        viewModel.podcast = podcast
    }
    fileprivate func setupViewModel(){
        viewModel.podcastUpdateObserver = { [weak self] podcast in
            self?.navigationItem.title = podcast.trackName
        }
    }
    fileprivate func setupTableView(){
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.cellID)
        tableView.eliminateExtraSeparators()
    }
    
    fileprivate func setupIsSearchingSubscriber(){
        let publisher = viewModel.$isSearching
        //Swift5.3改動 > 顯性的用capture list表明capture後,不用在block中隱性的加上self.xxx表明capture
        //但使用到weak / unowned宣告時還是得加self.xxx
        isSearchingSubscriber = publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (isSearching) in
                guard let self = self else { return }
                self.searchingView.isHidden = !isSearching
                self.checkIfEpisodeIsPlaying()
                self.tableView.reloadData()
            })
    }
    @objc fileprivate func handlePlayerStateUpdate(notification: Notification){
        guard let tabbarController = UIApplication.mainTabBarController else { return }
        let info = notification.userInfo
        let currentEpisode = info?[Notification.episodeKey]
        let previousEpisode = info?[Notification.previousEpisodeKey]
        //https://stackoverflow.com/questions/42033735/failing-cast-in-swift-from-any-to-protocol
        //https://appcoda.com.tw/any-anyobject/
        if let currentEpisode = currentEpisode as AnyObject as? EpisodeProtocol {
            if let index = viewModel.getEpisodeIndex(episode: currentEpisode) {
                viewModel.episodes[index].isPlaying = tabbarController.episodePlayerView.podcastPlayer.isPlayingItem
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
        if let previousEpisode = previousEpisode as AnyObject as? EpisodeProtocol {
            if let index = viewModel.getEpisodeIndex(episode: previousEpisode) {
                viewModel.episodes[index].isPlaying = false
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    fileprivate func checkIfPodcastDidFavorited(){
        let favoriteBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleFavorite))
        let podcastDidFavorited = viewModel.isPodcastFavorited(favorites: UserDefaults.standard.fetchFavoritePodcasts(), podcast: viewModel.podcast)
        navigationItem.rightBarButtonItem = podcastDidFavorited ? nil : favoriteBarButtonItem
    }
    @objc fileprivate func handleFavorite(){
        guard let podcast = viewModel.podcast as? Podcast else { return }
        let favoritedPodcast = FavoritedPodcast(podcast: podcast)
        viewModel.favoritePodcast(podcast: favoritedPodcast)
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
    //MARK: - TableView LifeCycle
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfEpisodes()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.cellID, for: indexPath) as! EpisodeCell
        let episode = viewModel.getEpisode(at: indexPath.row)
        cell.episodeViewModel = episode
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = viewModel.getEpisode(at: indexPath.row)
        let tabBarController = UIApplication.mainTabBarController
        tabBarController?.maximizePodcastPlayerView(episodeViewModel: episode, episodesList: viewModel.episodes)
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let episode = viewModel.getEpisode(at: indexPath.row)
        let episodeWasDownloaded = viewModel.isEpisodeDownloaded(downloads: UserDefaults.standard.fetchDownloadedEpisodes(), episode: episode)
        if episodeWasDownloaded { return nil }
        
        let downloadAction = UIContextualAction(style: .normal, title: "Download") { [self]  (_, _, _) in
            let episode = self.viewModel.getEpisode(at: indexPath.row)
            self.viewModel.downloadEpisode(episode: episode)
            //Reload cell to show downloadedImageView
            self.tableView.reloadRows(at: [indexPath], with: .none)
            //Update Badge
            let downloadController = UIApplication.mainTabBarController?.downloadController
            downloadController?.tabBarItem.badgeValue = "New"
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [downloadAction])
        return swipeActions
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
