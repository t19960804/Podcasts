//
//  DownloadController.swift
//  Podcasts
//
//  Created by t19960804 on 9/26/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit

class DownloadController: UITableViewController {
    
    var downloadedEpisodes = [EpisodeViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.cellID)
        tableView.eliminateExtraSeparators()
        NotificationCenter.default.addObserver(self, selector: #selector(handleProgressUpdate(notification:)), name: .progressUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEpisdoeDownloadDone(notification:)), name: .episodeDownloadDone, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarItem.badgeValue = nil
        downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisode()
        downloadedEpisodes.reverse()
        tableView.reloadData()
    }
    @objc fileprivate func handleEpisdoeDownloadDone(notification: Notification){
        downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisode()
        downloadedEpisodes.reverse()
        guard let episodeViewModel = notification.userInfo?["episodeViewModel"] as? EpisodeViewModel else {
            return
        }
        guard let index = downloadedEpisodes.firstIndex(where: {
            return $0.title == episodeViewModel.title && $0.author == episodeViewModel.author
        }) else {
            return
        }
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell
        cell?.descriptionLabel.text = episodeViewModel.description
        cell?.isUserInteractionEnabled = true
        cell?.alpha = 1
    }
    @objc fileprivate func handleProgressUpdate(notification: Notification){
        guard let progress = notification.userInfo?["progress"] as? Int, let episodeViewModel = notification.userInfo?["episodeViewModel"] as? EpisodeViewModel else {
            return
        }
        guard let index = downloadedEpisodes.firstIndex(where: {
            return $0.title == episodeViewModel.title && $0.author == episodeViewModel.author
        }) else {
            return
        }
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell
        cell?.descriptionLabel.text = "Downloading...\(progress)%"
        cell?.isUserInteractionEnabled = false
        cell?.alpha = 0.5
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
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
            //Remove episode file from FileManager and UserDefaults
            let episode = self.downloadedEpisodes[indexPath.row]
            guard let fileUrl = episode.fileUrl else { return }
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
}
