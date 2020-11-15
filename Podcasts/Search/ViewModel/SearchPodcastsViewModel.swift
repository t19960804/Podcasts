//
//  SearchPodcastsViewModel.swift
//  Podcasts
//
//  Created by t19960804 on 11/15/20.
//  Copyright © 2020 t19960804. All rights reserved.
//

import Foundation

class SearchPodcastsViewModel {
    //用Binding實作Reactive Programming
    var isSearching = false {
        didSet {
            isSearchingObserver?(isSearching)
        }
    }
    var podcasts = [Podcast]() {
        didSet {
           reloadController?(podcasts)
        }
    }
    var isSearchingObserver: ((Bool) -> ())?
    var reloadController: (([Podcast]) -> ())?
    
    func fetchPodcasts(searchText: String){
        isSearching = true
        podcasts = []
        
        NetworkService.sharedInstance.fetchPodcasts(searchText: searchText) { (result) in
            switch result {
            case .failure(let error):
                print("Request data failed:\(error)")
                self.podcasts = []
            case .success(let podcasts):
                self.podcasts = podcasts
            }
            self.isSearching = false
        }
    }
}
