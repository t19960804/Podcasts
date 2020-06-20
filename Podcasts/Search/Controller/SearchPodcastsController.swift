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
    let searchingView = SearchingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PodcastCell.self, forCellReuseIdentifier: cellID)
        tableView.eliminateExtraSeparators()
        setUpSearchController()
        setupConstraints()
    }
    fileprivate func setupConstraints(){
        view.addSubview(searchingView)
        searchingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 20).isActive = true
        searchingView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        searchingView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
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
        label.text = "Please enter a search query"
        label.textAlignment = .center
        label.textColor = .purple
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let searchBarIsEmpty = navigationItem.searchController!.searchBar.text!.isEmpty
        return podcasts.isEmpty && searchBarIsEmpty ? 250 : 0
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
        print(searchText)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
            self.searchingView.isHidden = false
            self.podcasts = []
            self.tableView.reloadData()
            
            NetworkService.sharedInstance.fetchPodcasts(searchText: searchText) {
                (podcasts) in
                self.searchingView.isHidden = true
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
