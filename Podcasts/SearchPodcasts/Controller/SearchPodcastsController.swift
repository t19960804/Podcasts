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
    let viewModel = SearchPodcastsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setUpSearchController()
        setupConstraints()
        searchBar(navigationItem.searchController!.searchBar, textDidChange: "Voong")
        setupObserver()
    }

    fileprivate func setupTableView(){
        //https://stackoverflow.com/questions/37352057/getting-black-screen-on-using-tab-bar-while-searching-using-searchcontroller/37357242#37357242
        definesPresentationContext = true//https://www.jianshu.com/p/b065413cbf57
        tableView.register(PodcastCell.self, forCellReuseIdentifier: cellID)
        tableView.eliminateExtraSeparators()
    }
    fileprivate func setupObserver(){
        //ViewController更趨近View的角色,不處理狀態與抓資料,只根據它們的變化而變化
        viewModel.isSearchingObserver = { [weak self] isSearching in
            self?.searchingView.isHidden = !isSearching
        }
        viewModel.reloadController = { [weak self] podcasts in
            self?.tableView.reloadData()
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
        return viewModel.podcasts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PodcastCell
        let podcast = viewModel.podcasts[indexPath.row]
        cell.podcast = podcast
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let input = navigationItem.searchController?.searchBar.text else { return nil }
        let label = UILabel(text: nil, font: .boldSystemFont(ofSize: 20), textColor: .purple, textAlignment: .center, numberOfLines: 0)
        //若是邏輯包含在生命週期內,就不需要特別跳脫週期去用Observer,因為Observer內還需要特別去create header再做轉型,增加code複雜度
        viewModel.searchBarInputUpdate(input: input)
        label.text = viewModel.headerLabelString
        return label
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //https://stackoverflow.com/questions/29144793/ios-swift-viewforheaderinsection-not-being-called
        return viewModel.calculateHeightForHeader()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = EpisodesListController()
        let podcast = viewModel.podcasts[indexPath.row]
        controller.viewModel.podcast = podcast
        navigationController?.pushViewController(controller, animated: true)
    }
}
extension SearchPodcastsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self](_) in
            self?.viewModel.fetchPodcasts(searchText: searchText)
        }
    }
    //function的型別 > 參數型別 + 回傳型別
    //可將function當成參數傳入另一個function
}
