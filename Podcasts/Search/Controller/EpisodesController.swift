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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: cellID)
        tableView.eliminateExtraSeparators()
        
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleFavorite)),
        UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetch))]
    }
    let commonKey = "podcast"
    //model object > data > UserDefaults > data > model object
    @objc fileprivate func handleFetch(){
        guard let data = UserDefaults.standard.data(forKey: commonKey) else { return }

        do {
            //Transform data to object
            let podcast = try JSONDecoder().decode(Podcast.self, from: data)
            print("Success get podcast from UserDefaults:\(podcast.artistName),\(podcast.trackName)")
        } catch {
            print("Error - Unarchive data to object failed:\(error)")
        }
    }
    @objc fileprivate func handleFavorite(){
        guard let podcast = self.podcast else { return }

        do {
            //Transform object to data
            let data = try JSONEncoder().encode(podcast)
            UserDefaults.standard.set(data, forKey: commonKey)
        } catch {
            print("Error - Archive object to data failed:\(error)")
        }

    }
    fileprivate func parseXMLFromURL(with url: String){
        guard let feedURL = URL(string: url) else { return }
        //不要將Network相關的code放在Controller
        NetworkService.sharedInstance.fetchEpisodes(url: feedURL) { (episodes) in
            self.episodeViewModels = episodes.map({
                return EpisodeViewModel(episode: $0)
            })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activityIndicatorView.isHidden = !episodeViewModels.isEmpty
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
    let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        activityIndicatorView.color = .purple
        return activityIndicatorView
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 200
    }
}
