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
    var episodes = [Episode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: cellID)
        tableView.eliminateExtraSeparators()
    }
    fileprivate func parseXMLFromURL(with url: String){
        guard let feedURL = URL(string: url) else { return }
        let xmlParser = FeedParser(URL: feedURL)
        xmlParser.parseAsync { (result) in
            //Associated Value > 把值夾帶在enum case中
            //https://hugolu.gitbooks.io/learn-swift/content/Advanced/Enum.html#associated_value
            switch result {
            case .success(let feed):
                //RSS > 以XML為基礎的內容傳送機制
                //Feed > 資料來源
                guard let rssFeed = feed.rssFeed else {
                    print("Error - rssFeed is nil")
                    return
                }
                rssFeed.items?.forEach {
                    let episode = Episode(item: $0)
                    self.episodes.append(episode)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print("Error - Parse XML failed:\(error)")
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
