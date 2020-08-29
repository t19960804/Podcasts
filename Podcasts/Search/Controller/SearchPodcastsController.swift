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
        //searchBar(navigationItem.searchController!.searchBar, textDidChange: "Brian voong")
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
        guard let input = navigationItem.searchController?.searchBar.text else { return nil }
        let label = UILabel(text: nil, font: .boldSystemFont(ofSize: 20), textColor: .purple, textAlignment: .center, numberOfLines: 0)

        label.text = input.isEmpty ? "Please enter a search query" : "There is no podcast about:\(input)"
        return label
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //https://stackoverflow.com/questions/29144793/ios-swift-viewforheaderinsection-not-being-called
        let isSearching = searchingView.isHidden == false
        if isSearching {
            return 0    //Searching中隱藏Header,高度為0時,viewForHeaderInSection不會觸發
        } else if isSearching == false && podcasts.isEmpty {
            return 250 //Searching完且沒有任何結果,秀出Header,並根據使用者有無輸入顯示不同內容
        }
        return 0 //Searching完且有結果,隱藏Header
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
            self.searchingView.isHidden = false
            self.podcasts = []
            self.tableView.reloadData()
            
            NetworkService.sharedInstance.fetchPodcasts(searchText: searchText) { (result) in
                switch result {
                case .failure(let error):
                    print("Request data failed:\(error)")
                    self.podcasts = []
                case .success(let podcasts):
                    self.podcasts = podcasts
                }
                self.searchingView.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
    //function的型別 > 參數型別 + 回傳型別
    //可將function當成參數傳入另一個function
}
