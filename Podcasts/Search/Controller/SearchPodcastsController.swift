//
//  SearchPodcastsController.swift
//  Podcasts
//
//  Created by t19960804 on 2/29/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import Alamofire

class SearchPodcastsController: UITableViewController {
    let cellID = "cellID"
    var podcasts = [Podcast]()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PodcastCell.self, forCellReuseIdentifier: cellID)
        tableView.eliminateExtraSeparators()
        setUpSearchController()
    }
    fileprivate func setUpSearchController(){
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate  = self
        searchController.searchBar.placeholder = "Search Podcasts..."
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false //固定searchBar
        //search時TableView的背景顏色是否變成灰底的
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
        
        searchBar(searchController.searchBar, textDidChange: "Voong")
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PodcastCell
        let podcast = podcasts[indexPath.row]
        cell.podcast = podcast
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No results, please enter a search query"
        label.textAlignment = .center
        label.textColor = .purple
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return podcasts.isEmpty ? 250 : 0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = EpisodesController()
        let podcast = podcasts[indexPath.row]
        controller.podcast = podcast
        navigationController?.pushViewController(controller, animated: true)
    }
}
extension SearchPodcastsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
            //以下兩個等價
            NetworkService.sharedInstance.fetchPodcasts(searchText: searchText) {
                (podcasts) in
                self.podcasts = podcasts
                self.tableView.reloadData()
            }
        }
        
//        NetworkService.sharedInstance.fetchPodcasts(searchText: searchText, completion: handlePodcastsResponse(podcasts:))
    }
    func handlePodcastsResponse(podcasts: [Podcast]) -> Void {
        self.podcasts = podcasts
        tableView.reloadData()
    }
    //function的型別 > 參數型別 + 回傳型別
    //可將function當成參數傳入另一個function
}
