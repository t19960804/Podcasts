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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
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
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let podcast = podcasts[indexPath.row]
        cell.textLabel?.text = "\(podcast.trackName ?? "Unknow")\n\(podcast.artistName)"
        cell.textLabel?.numberOfLines = 0
        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
        return cell
    }
    
}
extension SearchPodcastsController: UISearchBarDelegate {
    //requst url 範例: https://itunes.apple.com/search?term=jack+johnson&media=music
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let url = "https://itunes.apple.com/search"
        let extraParameters = ["term" : searchText,
                          "media" : "podcast"]
        //若輸入帶有空格的字串,會導致request失敗,須透過url encoding將"空格"轉換成"+"
        //例如: Brian Voong > Brian+Voong
        AF.request(url, method: .get, parameters: extraParameters, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { (response) in
            if let error = response.error {
                print("Request failed:\(error)")
                return
            }
            guard let data = response.data else {
                print("Request successly,but data has some problem")
                return
            }
            do {
                //將json data轉換成自訂類別
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                self.podcasts = searchResult.results
                self.tableView.reloadData()
            } catch {
                print("Decode json failed:\(error)")
            }
        }
    }
}
