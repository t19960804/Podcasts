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
    var timer: Timer?
    let searchingView = SearchingView()
    let searchPodcastsViewModel = SearchPodcastsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //https://stackoverflow.com/questions/37352057/getting-black-screen-on-using-tab-bar-while-searching-using-searchcontroller/37357242#37357242
        self.definesPresentationContext = true//https://www.jianshu.com/p/b065413cbf57
        tableView.register(PodcastCell.self, forCellReuseIdentifier: cellID)
        tableView.eliminateExtraSeparators()
        setUpSearchController()
        setupConstraints()
        searchBar(navigationItem.searchController!.searchBar, textDidChange: "Voong")
        setupObserver()
    }
    fileprivate func setupObserver(){
        //ViewController更趨近View的角色,不處理狀態與抓資料,只根據它們的變化而變化
        searchPodcastsViewModel.isSearchingObserver = { [self] isSearching in
            searchingView.isHidden = !isSearching
        }
        searchPodcastsViewModel.reloadController = { [self] podcasts in
            tableView.reloadData()
        }
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
        return searchPodcastsViewModel.podcasts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PodcastCell
        let podcast = searchPodcastsViewModel.podcasts[indexPath.row]
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
        let isSearching = searchPodcastsViewModel.isSearching
        if isSearching == false && searchPodcastsViewModel.podcasts.isEmpty {
            return 250 //Searching完且沒有任何結果,秀出Header,並根據使用者有無輸入顯示不同內容
        }
        return 0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = EpisodesController()
        let podcast = searchPodcastsViewModel.podcasts[indexPath.row]
        controller.podcast = podcast
        navigationController?.pushViewController(controller, animated: true)
    }
}
extension SearchPodcastsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
            self.searchPodcastsViewModel.fetchPodcasts(searchText: searchText)
        }
    }
    //function的型別 > 參數型別 + 回傳型別
    //可將function當成參數傳入另一個function
}
