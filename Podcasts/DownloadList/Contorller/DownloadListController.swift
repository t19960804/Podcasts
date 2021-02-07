//
//  DownloadController.swift
//  Podcasts
//
//  Created by t19960804 on 9/26/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import Combine

class DownloadListController: UITableViewController {
    
    let viewModel = DownloadListViewModel()
    private var progressUpdateSubscriber: AnyCancellable?
    private var episodeDownloadDoneSubscriber: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.cellID)
        tableView.eliminateExtraSeparators()
        setupProgressUpdateSubscriber()
        setupEpisodeDownloadDoneSubscriber()
        setupNotificationCenter()
    }
    fileprivate func setupNotificationCenter(){
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerStateUpdate(notification:)), name: .playerStateUpdate, object: nil)
    }
    fileprivate func setupEpisodeDownloadDoneSubscriber(){
        let publisher = NotificationCenter.default.publisher(for: .episodeDownloadDone)
        episodeDownloadDoneSubscriber = publisher
            .map{$0.userInfo?[Notification.episodeKey] as! EpisodeCellViewModel}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] episodeViewModel in
                guard let self = self else { return }
                self.viewModel.downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
                guard let index = self.viewModel.getIndexOfEpisode(episodeViewModel) else { return }
                //不可以用cell.episodeViewModel = episodeViewModel,這種做法需要搭配.reloadData()
                let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell
                cell?.durationLabel.text = episodeViewModel.duration
                cell?.isUserInteractionEnabled = true
                cell?.contentView.backgroundColor = .clear
            }
    }
    fileprivate func setupProgressUpdateSubscriber(){
        let publisher = NotificationCenter.default.publisher(for: .progressUpdate)
        progressUpdateSubscriber = publisher
            .map{($0.userInfo?[Notification.progressKey] as! Int,$0.userInfo?[Notification.episodeKey] as! EpisodeCellViewModel)}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (progress, episodeViewModel) in
                guard let self = self else { return }
                guard let index = self.viewModel.getIndexOfEpisode(episodeViewModel) else { return }
                let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell
                cell?.durationLabel.text = "Downloading...\(progress)%"
            }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarItem.badgeValue = nil
        viewModel.downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
        checkIfEpisodeIsPlaying()
        tableView.reloadData()
    }
    @objc fileprivate func handlePlayerStateUpdate(notification: Notification){
        guard let tabbarController = UIApplication.mainTabBarController else { return }
        let info = notification.userInfo
        let currentEpisode = info?[Notification.episodeKey]
        let previousEpisode = info?[Notification.previousEpisodeKey]
        if let currentEpisode = currentEpisode as AnyObject as? EpisodeProtocol {
            if let index = viewModel.getIndexOfEpisode(currentEpisode) {
                viewModel.downloadedEpisodes[index].isPlaying = tabbarController.episodePlayerView.podcastPlayer.isPlayingItem
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
        if let previousEpisode = previousEpisode  as AnyObject as? EpisodeProtocol {
            if let index = viewModel.getIndexOfEpisode(previousEpisode) {
                viewModel.downloadedEpisodes[index].isPlaying = false
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    fileprivate func checkIfEpisodeIsPlaying(){
        guard let tabbarController = UIApplication.mainTabBarController else { return }
        let currentEpisodePlaying = tabbarController.episodePlayerView.viewModel.currentEpisode
        if let index = viewModel.getIndexOfEpisode(currentEpisodePlaying) {
            viewModel.downloadedEpisodes[index].isPlaying = tabbarController.episodePlayerView.podcastPlayer.isPlayingItem
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfEpisodes()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: EpisodeCell.cellID, for: indexPath) as! EpisodeCell
        cell.episodeViewModel = viewModel.getEpisode(at: indexPath.row)
        cell.downloadedImageView.isHidden = true
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [self]  (_, _, _) in
            //Remove episode file from FileManager and UserDefaults
            let episode = viewModel.getEpisode(at: indexPath.row)
            guard let fileUrl = episode.fileUrl?.getTrueLocation() else {
                print("Error - Can't get true fileUrl")
                return
            }
            viewModel.removeEpisodeFromFileManager(url: fileUrl)
            viewModel.downloadedEpisodes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            //若當前有兩個podcast,一個在播放,刪除另一個時,會把正在播放的狀態一起save,導致下次開機時podcast維持在播的狀態
            guard let tabbarController = UIApplication.mainTabBarController else { return }
            let currentEpisodePlaying = tabbarController.episodePlayerView.viewModel.currentEpisode
            viewModel.removeEpisodeFromUserDefaults(episode: currentEpisodePlaying)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodeViewModel = viewModel.getEpisode(at: indexPath.row)
        let tabBarController = UIApplication.mainTabBarController
        tabBarController?.maximizePodcastPlayerView(episodeViewModel: episodeViewModel, episodesList: viewModel.downloadedEpisodes)
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel(text: "No Downloaded Episodes!", font: .boldSystemFont(ofSize: 20), textColor: .purple, textAlignment: .center, numberOfLines: 0)
        return label
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        viewModel.calculateHeightForFooter()
        return viewModel.heightForFooter
    }
}
