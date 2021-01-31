//
//  SearchPodcastsViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 11/15/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import UIKit
import Combine

class SearchPodcastsViewModel {
    //Fetch Data
    //讓Property變成Publisher
    @Published var isSearching = false
    
    var podcasts = [Podcast]() {
        didSet {
           reloadController?(podcasts)
        }
    }
    var reloadController: (([Podcast]) -> ())?
    
    func fetchPodcasts(searchText: String){
        isSearching = true
        podcasts = []
        
        NetworkService.sharedInstance.fetchPodcasts(searchText: searchText) { (result) in
            switch result {
            case .failure(let error):
                print("Err - Request data failed: \(error.localizedDescription)")
                self.podcasts = []
            case .success(let podcasts):
                self.podcasts = podcasts
            }
            self.isSearching = false
        }
    }
    //SearchBar
    var headerLabelString = ""
    func searchBarInputUpdate(input: String){
        headerLabelString = input.isEmpty ? "Please enter a search query" : "There is no podcast about: \(input)"
    }
    //HeightForHeader
    func calculateHeightForHeader() -> CGFloat {
        if isSearching == false && podcasts.isEmpty {
             return 250//Searching完且沒有任何結果,秀出Header,並根據使用者有無輸入顯示不同內容
        } else {
            return 0
        }
    }
}
