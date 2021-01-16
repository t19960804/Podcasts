//
//  DownloadController.swift
//  Podcasts
//
//  Created by t19960804 on 9/26/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class DownloadListController: UITableViewController {
    
    let viewModel = DownloadListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.cellID)
        tableView.eliminateExtraSeparators()
        setupNotificationCenter()
    }
    fileprivate func setupNotificationCenter(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleProgressUpdate(notification:)), name: .progressUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEpisdoeDownloadDone(notification:)), name: .episodeDownloadDone, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerStateUpdate(notification:)), name: .playerStateUpdate, object: nil)
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
    @objc fileprivate func handleEpisdoeDownloadDone(notification: Notification){
        viewModel.downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
        guard let episodeViewModel = notification.userInfo?[Notification.episodeKey] as? EpisodeCellViewModel else {
            return
        }
        guard let index = viewModel.getIndexOfEpisode(episodeViewModel) else { return }
        //不可以用cell.episodeViewModel = episodeViewModel,這種做法需要搭配.reloadData()
        DispatchQueue.main.async {
            let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell
            cell?.durationLabel.text = episodeViewModel.duration
            cell?.isUserInteractionEnabled = true
            cell?.contentView.backgroundColor = .clear
        }
        
    }
    @objc fileprivate func handleProgressUpdate(notification: Notification){
        guard let progress = notification.userInfo?[Notification.progressKey] as? Int, let episodeViewModel = notification.userInfo?[Notification.episodeKey] as? EpisodeCellViewModel else {
            return
        }
        guard let index = viewModel.getIndexOfEpisode(episodeViewModel) else { return }
        DispatchQueue.main.async {
            let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell
            cell?.durationLabel.text = "Downloading...\(progress)%"
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
