//
//  SearchPodcastsController.swift
//  Podcasts
//
//  Created by t19960804 on 2/29/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import Combine

class SearchPodcastsController: UITableViewController {
    private let cellID = "cellID"
    private let searchingView = SearchingView()
    private let viewModel = SearchPodcastsViewModel()
    private var searchTextFieldSubscriber: AnyCancellable?
    private var isSearchingSubscriber: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setUpSearchController()
        setupConstraints()
        setupObserver()
        
        viewModel.fetchPodcasts(searchText: "Voong")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupIsSearchingSubscriber()
        setupSearchTextFieldSubscriber()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextFieldSubscriber?.cancel()
        isSearchingSubscriber?.cancel()
    }
    fileprivate func setupTableView(){
        //https://stackoverflow.com/questions/37352057/getting-black-screen-on-using-tab-bar-while-searching-using-searchcontroller/37357242#37357242
        definesPresentationContext = true//https://www.jianshu.com/p/b065413cbf57
        tableView.register(PodcastCell.self, forCellReuseIdentifier: cellID)
        tableView.eliminateExtraSeparators()
    }
    fileprivate func setupObserver(){
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
        searchController.searchBar.placeholder = "Search Podcasts..."
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false //固定searchBar
        //search時TableView的背景顏色是否變成灰底的
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
    }
    fileprivate func setupIsSearchingSubscriber(){
        let publisher = viewModel.$isSearching
        isSearchingSubscriber = publisher
            .map { !$0 }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isHidden, on: searchingView) //回傳AnyCancellable,代表訂閱關係成立,這段關係可以隨時被Cancel
    }
    fileprivate func setupSearchTextFieldSubscriber(){
        //https://stackoverflow.com/questions/60241335/somehow-combine-with-search-controller-not-working-any-idea
        let publisher = NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: navigationItem.searchController?.searchBar.searchTextField)
        searchTextFieldSubscriber = publisher
            .map { (($0.object as! UISearchTextField).text ?? "") }
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates() //若0.5秒過後,element還是跟上一次一樣,就不往下傳element
            .receive(on: RunLoop.main)
            .sink(receiveValue: {[weak self] in
                self?.viewModel.fetchPodcasts(searchText: $0)
            })
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
