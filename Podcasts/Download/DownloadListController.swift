//
//  DownloadController.swift
//  Podcasts
//
//  Created by t19960804 on 9/26/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class DownloadListController: UITableViewController {
    
    var downloadedEpisodes = [EpisodeViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.cellID)
        tableView.eliminateExtraSeparators()
        NotificationCenter.default.addObserver(self, selector: #selector(handleProgressUpdate(notification:)), name: .progressUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEpisdoeDownloadDone(notification:)), name: .episodeDownloadDone, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerStateUpdate(notification:)), name: .playerStateUpdate, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarItem.badgeValue = nil
        downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
        downloadedEpisodes.reverse()//讓最新加入下載的Episode出現在最上面
        checkIfEpisodeIsPlaying()//因為上面重新fetch,每一個episode的isPlaying都是false.所以要check
        tableView.reloadData()
    }
    @objc fileprivate func handlePlayerStateUpdate(notification: Notification){
        guard let tabbarController = UIApplication.mainTabBarController else { return }
        let info = notification.userInfo
        if let currentEpisode = info?[Notification.episodeKey] as? EpisodeViewModel {
            if let index = downloadedEpisodes.firstIndex(where: {
                $0.title == currentEpisode.title && $0.author == currentEpisode.author
            })  {
                downloadedEpisodes[index].isPlaying = tabbarController.episodePlayerView.podcastPlayer.isPlayingItem
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
        if let previousEpisode = info?[Notification.previousEpisodeKey] as? EpisodeViewModel {
            if let index = downloadedEpisodes.firstIndex(where: {
                $0.title == previousEpisode.title && $0.author == previousEpisode.author
            }) {
                downloadedEpisodes[index].isPlaying = false
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    fileprivate func checkIfEpisodeIsPlaying(){
        guard let tabbarController = UIApplication.mainTabBarController else { return }
        let currentEpisodePlaying = tabbarController.episodePlayerView.episodeViewModel
        if let index = downloadedEpisodes.firstIndex(where: {
            $0.title == currentEpisodePlaying?.title && $0.author == currentEpisodePlaying?.author
        }) {
            downloadedEpisodes[index].isPlaying = tabbarController.episodePlayerView.podcastPlayer.isPlayingItem
        }
    }
    @objc fileprivate func handleEpisdoeDownloadDone(notification: Notification){
        downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
        downloadedEpisodes.reverse()//讓最新加入下載的Episode出現在最上面
        guard let episodeViewModel = notification.userInfo?[Notification.episodeKey] as? EpisodeViewModel else {
            return
        }
        guard let index = downloadedEpisodes.firstIndex(where: {
            return $0.title == episodeViewModel.title && $0.author == episodeViewModel.author
        }) else {
            return
        }
        //不可以用cell.episodeViewModel = episodeViewModel,這種做法需要搭配.reloadData()
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell
        cell?.durationLabel.text = episodeViewModel.duration
        cell?.isUserInteractionEnabled = true
        cell?.contentView.backgroundColor = .clear
    }
    @objc fileprivate func handleProgressUpdate(notification: Notification){
        guard let progress = notification.userInfo?[Notification.progressKey] as? Int, let episodeViewModel = notification.userInfo?[Notification.episodeKey] as? EpisodeViewModel else {
            return
        }
        guard let index = downloadedEpisodes.firstIndex(where: {
            return $0.title == episodeViewModel.title && $0.author == episodeViewModel.author
        }) else {
            return
        }
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell
        cell?.durationLabel.text = "Downloading...\(progress)%"
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedEpisodes.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: EpisodeCell.cellID, for: indexPath) as! EpisodeCell
        cell.episodeViewModel = downloadedEpisodes[indexPath.row]
        cell.downloadedImageView.isHidden = true
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
            //Remove episode file from FileManager and UserDefaults
            let episode = self.downloadedEpisodes[indexPath.row]
            guard let fileUrl = episode.fileUrl?.getTrueLocation() else {
                print("Error - Can't get true fileUrl")
                return
            }
            do {
               try FileManager.default.removeItem(at: fileUrl)
            } catch {
                print("Error - Remove downloaded file failed:\(error)")
            }
            
            self.downloadedEpisodes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            UserDefaults.standard.saveDownloadEpisode(with: self.downloadedEpisodes)
        }
        return [deleteAction]
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodeViewModel = downloadedEpisodes[indexPath.row]
        let tabBarController = UIApplication.mainTabBarController
        tabBarController?.maximizePodcastPlayerView(episodeViewModel: episodeViewModel, episodesList: downloadedEpisodes)
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel(text: "No Downloaded Episodes!", font: .boldSystemFont(ofSize: 20), textColor: .purple, textAlignment: .center, numberOfLines: 0)
        return label
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return downloadedEpisodes.isEmpty ? 200 : 0
    }
}
