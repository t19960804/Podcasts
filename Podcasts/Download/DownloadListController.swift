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
            if let index = getIndexOfEpisode(currentEpisode) {
                downloadedEpisodes[index].isPlaying = tabbarController.episodePlayerView.podcastPlayer.isPlayingItem
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
        if let previousEpisode = info?[Notification.previousEpisodeKey] as? EpisodeViewModel {
            if let index = getIndexOfEpisode(previousEpisode) {
                downloadedEpisodes[index].isPlaying = false
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    fileprivate func checkIfEpisodeIsPlaying(){
        guard let tabbarController = UIApplication.mainTabBarController else { return }
        let currentEpisodePlaying = tabbarController.episodePlayerView.episodeViewModel
        if let index = getIndexOfEpisode(currentEpisodePlaying) {
            downloadedEpisodes[index].isPlaying = tabbarController.episodePlayerView.podcastPlayer.isPlayingItem
        }
    }
    @objc fileprivate func handleEpisdoeDownloadDone(notification: Notification){
        downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
        downloadedEpisodes.reverse()//讓最新加入下載的Episode出現在最上面
        guard let episodeViewModel = notification.userInfo?[Notification.episodeKey] as? EpisodeViewModel else {
            return
        }
        guard let index = getIndexOfEpisode(episodeViewModel) else { return }
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
        guard let index = getIndexOfEpisode(episodeViewModel) else { return }
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell
        cell?.durationLabel.text = "Downloading...\(progress)%"
    }
    func getIndexOfEpisode(_ episode: EpisodeViewModel?) -> Int? {
        guard let index = downloadedEpisodes.firstIndex(where: {
            $0.title == episode?.title && $0.author == episode?.author
        }) else {
            return nil
        }
        return index
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
            //若當前有兩個podcast,一個在播放,刪除另一個時,會把正在播放的狀態一起save,導致下次開機時podcast維持在播的狀態
            guard let tabbarController = UIApplication.mainTabBarController else { return }
            let currentEpisodePlaying = tabbarController.episodePlayerView.episodeViewModel
            if let index = self.getIndexOfEpisode(currentEpisodePlaying) {
                //先把狀態改為false並存起來,存完再打開
                self.downloadedEpisodes[index].isPlaying = false
                UserDefaults.standard.saveDownloadEpisode(with: self.downloadedEpisodes)
                self.downloadedEpisodes[index].isPlaying = true
            } else {
                UserDefaults.standard.saveDownloadEpisode(with: self.downloadedEpisodes)
            }
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